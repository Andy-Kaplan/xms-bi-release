# Microservice Report Database Reference

> **Source:** UAT environment (`xms-mssql-ne-uat`, Azure SQL Database)
> **Database:** `report`
> **Audited:** 2026-03-11 via MCP read-only inspection
> **Purpose:** Dashboard configuration store for the XMS front-end application

## 1. Overview

The `report` database is the **microservice-side configuration store** that drives the XMS BI dashboard front end. It contains no analytical data — that lives in the per-organisation databases on the XMS BI SQL Server Managed Instance. Instead, this database controls:

- **Which organisations** can see which card types (visualisation access control)
- **Which datasets** are wired to which card types per organisation
- **Dashboard layouts** — grid definitions, item placement, responsive breakpoints
- **Colour palettes** — system defaults + organisation/staff overrides
- **Dashboard navigation** — groups, naming, icons, sort order (partially implemented)

The database bridges the microservice layer and the BI Managed Instance through two key tokens:
1. **`DbPrefix`** (in `BiConfig`) — resolves to the MI database name: `{DbPrefix}_XMS_{OrganisationId}`
2. **`DataSet`** (in `DashboardGridItem`, `DashboardGridFilter`, `VisualisationDataSetMap`) — matches `DataSetName` in `core.core.VisualisationQueries` on the MI

### Server Details

| Property | Value |
|---|---|
| Server | `xms-mssql-ne-uat` |
| Edition | SQL Azure (Azure SQL Database) |
| Databases on server | 18 (one per microservice domain) |
| Cross-database queries | Not supported (Azure SQL DB limitation) |
| MCP connection | `microservice-uat` connects to `report`; `microservice-uat-report` connects to `master` (read-only) |

### Sibling Databases (same server)

| Database | Domain |
|---|---|
| `assignment` | Staff/resource assignment |
| `authorization` | Auth/permissions |
| `feature` | Feature flags |
| `location` | Location/venue data |
| `menu` | Menu structures |
| `notification` | Push/email notifications |
| `order` | Order processing |
| `organisation` | Organisation registry |
| `payment` | Payment processing |
| `price` | Pricing rules |
| `product` | Product catalog |
| `reference` | Reference/lookup data |
| `report` | **Dashboard configuration (this doc)** |
| `reservation` | Table reservations |
| `resource` | Resource management |
| `staff` | Staff profiles |
| `survey` | Survey definitions |
| `userlogin` | User authentication |

---

## 2. Schema Architecture

Three schemas:

| Schema | Purpose | Tables | Triggers | Stored Procedures |
|---|---|---|---|---|
| `dbo` | Live configuration data | 21 | 40 | 148 |
| `Audit` | Change history (mirror of dbo) | 20 | 0 | 0 |
| `RoundhousE` | Migration tracking | 3 | 0 | 0 |

### Table Inventory

| Schema | Table | Rows | Purpose |
|---|---|---|---|
| **dbo** | `AppVersion` | 9 | Application deployment version log |
| | `BiConfig` | 8 | Organisation-to-MI-database mapping |
| | `VisualisationProcedure` | 16 | Card type SP registry |
| | `VisualisationConfig` | 65 | Organisation access to card types |
| | `VisualisationDataSetMap` | 101 | Dataset assignments per org+card type |
| | `DashboardGrid` | 7 | Grid layout containers |
| | `DashboardGridItem` | 61 | Cards placed on grids |
| | `DashboardGridFilter` | 28 | Filter widgets on grids |
| | `DashboardConfig` | 0 | Platform-default dashboard naming (unused) |
| | `DashboardGroup` | 0 | Navigation group hierarchy (unused) |
| | `DashboardGroupMapping` | 0 | Group-to-config junction (unused) |
| | `DashboardPalette` | 11 | System colour palettes |
| | `DashboardPaletteColour` | 90 | Colours within palettes |
| | `OrganisationDashboardConfig` | 14 | Org-scoped dashboard naming/assignment |
| | `OrganisationDashboardGroupMapping` | 0 | Org group-to-config junction (unused) |
| | `OrganisationDashboardPalette` | 1 | Org palette override (seed data) |
| | `OrganisationDashboardPaletteColour` | 1 | Org palette colour override (seed data) |
| | `StaffDashboardConfig` | 0 | Staff-scoped dashboard config (unused) |
| | `StaffDashboardGroupMapping` | 0 | Staff group-to-config junction (unused) |
| | `StaffDashboardPalette` | 1 | Staff palette override (seed data) |
| | `StaffDashboardPaletteColour` | 1 | Staff palette colour override (seed data) |
| **Audit** | *(20 tables)* | — | Mirror of each dbo table except AppVersion |
| **RoundhousE** | `Version` | 21 | Migration version history |
| | `ScriptsRun` | 67 | Deployed script log |
| | `ScriptsRunErrors` | 0 | Script error log |

### Common Column Patterns

Every dbo table (except `AppVersion`) follows a uniform pattern:

| Column | Type | Purpose |
|---|---|---|
| `{Table}Id` | `uniqueidentifier` (DEFAULT `NEWSEQUENTIALID()`) | Primary key |
| `TransactionId` | `bigint IDENTITY` | Optimistic concurrency / event sequence (clustered index, auto-incremented) |
| `IsDeleted` | `bit NOT NULL` (no default) | Soft-delete flag (never physically deleted). **Must be explicitly set to `0` in INSERT statements** — there is no DEFAULT constraint. |
| `DateCreated` | `datetime2` (DEFAULT `SYSUTCDATETIME()`) | UTC creation timestamp |
| `DateUpdated` | `datetime2` (DEFAULT `SYSUTCDATETIME()`) | UTC last-update (maintained by `_Updated` trigger) |

### Indexing Strategy

All tables use a dual-index pattern:

| Index | Type | Key |
|---|---|---|
| `CX_{Table}_TransactionId` | **Clustered**, unique | `TransactionId` — physical row order by write sequence |
| `PK_{Table}` | Non-clustered, unique | `{Table}Id` (GUID) — logical primary key |

This design optimises for append-heavy workloads: new rows are physically appended in write order (ascending bigint), while GUID lookups use a secondary index.

**Exception:** `VisualisationProcedure` has a third unique index `UQ_VisualisationProcedure_SingleActive` enforcing one active procedure per `VisualisationId`.

---

## 3. Core Configuration Tables

### 3.1 BiConfig — Organisation-to-Database Mapping

**Purpose:** Links each organisation to its database on the XMS BI Managed Instance. The front end uses `DbPrefix` + `OrganisationId` to construct the MI database name: `{DbPrefix}_XMS_{OrganisationId}`.

| Column | Type | Nullable | Notes |
|---|---|---|---|
| `BiConfigId` | `uniqueidentifier` | NOT NULL | PK |
| `TransactionId` | `bigint` | NOT NULL | |
| `OrganisationId` | `uniqueidentifier` | NOT NULL | Organisation GUID (from `organisation` microservice DB) |
| `DbPrefix` | `nvarchar(8)` | NOT NULL | Date prefix for MI database name (e.g. `20260129`) |
| `IsDeleted` | `bit` | NOT NULL | |
| `DateCreated` | `datetime2` | NOT NULL | |
| `DateUpdated` | `datetime2` | NOT NULL | |

**Current data (8 organisations):**

| OrganisationId | DbPrefix | MI Database Name |
|---|---|---|
| `C14CF568-...` | `20250917` | `20250917_XMS_C14CF568-...` |
| `8381A215-...` | `20260202` | `20260202_XMS_8381A215-...` |
| `B55413A0-...` | `20260129` | `20260129_XMS_B55413A0-...` |
| `5AD1BEAC-...` | `20260129` | `20260129_XMS_5AD1BEAC-...` (KUDU) |
| `A99E3EBA-...` | `20260129` | `20260129_XMS_A99E3EBA-...` |
| `B34DA7C3-...` | `20260129` | `20260129_XMS_B34DA7C3-...` |
| `7F1917D0-...` | `20260129` | `20260129_XMS_7F1917D0-...` |
| `5C4F9C3D-...` | `20260129` | `20260129_XMS_5C4F9C3D-...` |

**Note:** Organisation `3EBF26FE-...` (NeighboursSurvey/SurveyHero) has `VisualisationConfig` and `OrganisationDashboardConfig` rows but no `BiConfig` entry — the microservice cannot resolve its MI database.

### 3.2 VisualisationProcedure — Card Type Registry

**Purpose:** Maps integer `VisualisationId` values to stored procedure names on the MI client databases. These are the card-type SPs that execute visualisation queries.

| Column | Type | Nullable | Notes |
|---|---|---|---|
| `VisualisationProcedureId` | `uniqueidentifier` | NOT NULL | PK |
| `TransactionId` | `bigint` | NOT NULL | |
| `VisualisationId` | `int` | NOT NULL | Integer card type identifier (unique) |
| `ProcedureName` | `nvarchar(1024)` | NOT NULL | Fully qualified SP name (e.g. `core.SingleKPICard`) |
| `IsDeleted` | `bit` | NOT NULL | |
| `DateCreated` | `datetime2` | NOT NULL | |
| `DateUpdated` | `datetime2` | NOT NULL | |

**All 16 card types:**

| VisualisationId | ProcedureName | Added |
|---|---|---|
| 1 | `core.BarChartCard` | 2025-12-16 |
| 2 | `core.CombinedChartCard` | 2025-12-16 |
| 3 | `core.CustomDataGrid` | 2025-12-16 |
| 4 | `core.CustomGroupedDataGrid` | 2025-12-16 |
| 5 | `core.CustomPinnedDataGrid` | 2025-12-16 |
| 6 | `core.HeatmapCard` | 2025-12-16 |
| 7 | `core.LineChartCard` | 2025-12-16 |
| 8 | `core.MultiLineChartCard` | 2025-12-16 |
| 9 | `core.PieChartCard` | 2025-12-16 |
| 10 | `core.SingleKPICard` | 2025-12-16 |
| 11 | `core.StackedBarChartCard` | 2025-12-16 |
| 12 | `core.StatCard` | 2025-12-16 |
| 13 | `core.TreeViewCard` | 2025-12-16 |
| 15 | `core.RadarChartCard` | 2026-02-17 |
| 16 | `core.StaticBoxCard` | 2026-02-17 |
| 17 | `core.MarkdownCard` | 2026-02-17 |

**Notes:**
- `VisualisationId` 14 is missing — `FilterList` is handled separately by the microservice (not via a card SP), so it has no entry here.
- `core.StaticBoxCard` (id 16) exists in UAT but is not yet in the MI release scripts — it appears to be a new card type under development.
- IDs 1–13 were seeded at initial DB creation; 15–17 were added later as a batch.

### 3.3 VisualisationConfig — Organisation Card Access

**Purpose:** Grants an organisation access to a specific card type with an optional temporal validity window. Each row = "org X can use card type Y from date A to date B".

| Column | Type | Nullable | Notes |
|---|---|---|---|
| `VisualisationConfigId` | `uniqueidentifier` | NOT NULL | PK |
| `TransactionId` | `bigint` | NOT NULL | |
| `OrganisationId` | `uniqueidentifier` | NOT NULL | |
| `VisualisationId` | `int` | NOT NULL | Card type (joins to `VisualisationProcedure`) |
| `ActiveFrom` | `datetime` | NOT NULL | Start of validity period |
| `ActiveUntil` | `datetime` | YES | End of validity (NULL = no expiry) |
| `IsDeleted` | `bit` | NOT NULL | |
| `DateCreated` | `datetime2` | NOT NULL | |
| `DateUpdated` | `datetime2` | NOT NULL | |

**Summary:** 65 rows, 64 active, 9 distinct organisations. All `ActiveUntil` values are NULL (temporal expiry has never been used). The most-provisioned org (`C14CF568-...`) has 15 card types; the 6 TG Restaurant orgs with `DbPrefix=20260129` each have 6 card types (CombinedChart, PieChart, SingleKPI, StackedBar, StaticBox, Markdown).

### 3.4 VisualisationDataSetMap — Dataset Wiring

**Purpose:** Maps a `VisualisationConfig` (org + card type) to one or more named datasets. The `DataSet` string is the cross-system key that corresponds to `DataSetName` in `core.core.VisualisationQueries` on the MI.

| Column | Type | Nullable | Notes |
|---|---|---|---|
| `VisualisationDataSetMapId` | `uniqueidentifier` | NOT NULL | PK |
| `TransactionId` | `bigint` | NOT NULL | |
| `VisualisationConfigId` | `uniqueidentifier` | NOT NULL | FK to `VisualisationConfig` |
| `DataSet` | `nvarchar(1024)` | NOT NULL | Named dataset token |
| `IsDeleted` | `bit` | NOT NULL | |
| `DateCreated` | `datetime2` | NOT NULL | |
| `DateUpdated` | `datetime2` | NOT NULL | |

**Summary:** 101 rows, 100 active, 40 distinct dataset names across 4 domains:

| Domain | Datasets | Examples |
|---|---|---|
| Inventory (`Inv*`) | 19 | `InvTheoMargin`, `InvCountVariance`, `InvNetSales`, `InvWasteCost`, `InvTop20Variance` |
| Sales/POS | 7 | `NetSales`, `NetSalesByHour`, `ProductMargins`, `Discounts`, `DiscountPerc` |
| RedLion (bespoke) | 12 | `RedLionNetSales`, `RedLionCatMix`, `RedLionProdAttach`, `RedLionWeeklyPattern` |
| Survey | 2 | `SurveyAgeByGender`, `SurveyDistanceTransport` |

**Known data issues:**
- `InvUseAnalisys` — misspelling of `InvUseAnalysis` (must match MI exactly)
- `RedLionNetsSalesLW` — typo (extra 's'), soft-deleted and replaced by `RedLionNetSalesLW`

### 3.5 AppVersion — Deployment Log

**Purpose:** Append-only log of application versions deployed against this database. Not audited.

| Column | Type | Nullable | Notes |
|---|---|---|---|
| `AppVersionId` | `int` | NOT NULL | PK (identity) |
| `Number` | `varchar(10)` | NOT NULL | Version string (`1.0.{build}`) |
| `DateCreated` | `datetime` | NOT NULL | DEFAULT `GETUTCDATE()` |
| `DateUpdated` | `datetime` | NOT NULL | DEFAULT `GETUTCDATE()` |

**Current versions:** 9 entries from `1.0.0` (2025-12-16) to `1.0.64927` (2026-02-10). The build number is a CI/CD counter incrementing at ~300/week.

---

## 4. Dashboard Layout Tables

### 4.1 DashboardGrid — Layout Containers

**Purpose:** Defines a MUI Grid layout container. Grids have no name — identity comes from whichever config table (`DashboardConfig`, `OrganisationDashboardConfig`, or `StaffDashboardConfig`) points to them.

| Column | Type | Nullable | Notes |
|---|---|---|---|
| `DashboardGridId` | `uniqueidentifier` | NOT NULL | PK |
| `TransactionId` | `bigint` | NOT NULL | |
| `Container` | `bit` | NOT NULL | MUI Container wrapper (all = true) |
| `Spacing` | `int` | NOT NULL | MUI Grid spacing (all = 2) |
| `Columns` | `int` | NOT NULL | Grid column count (all = 12) |
| `IsDeleted` | `bit` | NOT NULL | |
| `DateCreated` | `datetime2` | NOT NULL | |
| `DateUpdated` | `datetime2` | NOT NULL | |

**7 grids** (identified via `OrganisationDashboardConfig` names):

| DashboardGridId (short) | Dashboard Name(s) | Live Items | Live Filters |
|---|---|---|---|
| `0FFD9CDC` | Inventory Analysis | 4 | 2 (Locations, InvItems) |
| `E4026650` | Survey Overview | 0 | 0 |
| `B2B48671` | Lifestyle Provision | 0 | 0 |
| `050FCDB8` | Margin Management | 10 | 1 (Locations) |
| `C0000280` | Test Matt Dashboard | 9 | 1 (InvItems) |
| `C87B90C5` | Dashboard Demo 2 | 3 | 2 (RedLionXProd, RedLionYProd) |
| `1B161CBA` | Dashboard Demo 1 | 9 | 6 (RedLion filters) |

### 4.2 DashboardGridItem — Card Placement

**Purpose:** Places a visualisation card on a grid at a specific position with responsive column spans.

| Column | Type | Nullable | Notes |
|---|---|---|---|
| `DashboardGridItemId` | `uniqueidentifier` | NOT NULL | PK |
| `TransactionId` | `bigint` | NOT NULL | |
| `DashboardGridId` | `uniqueidentifier` | NOT NULL | FK to `DashboardGrid` |
| `ExtraSmall` | `int` | NOT NULL | MUI `xs` breakpoint column span (1–12) |
| `Small` | `int` | YES | MUI `sm` breakpoint |
| `Medium` | `int` | YES | MUI `md` breakpoint |
| `Large` | `int` | YES | MUI `lg` breakpoint |
| `ExtraLarge` | `int` | YES | MUI `xl` breakpoint |
| `VisualisationId` | `int` | NOT NULL | Card type (semantic join to `VisualisationProcedure.VisualisationId` — no FK constraint) |
| `DataSet` | `nvarchar(1024)` | NOT NULL | Dataset token (matches MI `DataSetName`) |
| `IsDeleted` | `bit` | NOT NULL | |
| `DateCreated` | `datetime2` | NOT NULL | |
| `DateUpdated` | `datetime2` | NOT NULL | |
| `SortOrder` | `int` | NOT NULL | Position within the grid |

**Responsive breakpoint patterns (common):**
- KPI cards (`SingleKPICard`, id 10): typically span 3 columns across all breakpoints
- Chart cards: typically span 6–12 columns
- Full-width items: 12 across all breakpoints

**Card types in active use:**

| VisualisationId | Card Type | Live Items |
|---|---|---|
| 2 | CombinedChartCard | 4 |
| 3 | CustomDataGrid | 1 |
| 4 | CustomGroupedDataGrid | 1 |
| 6 | HeatmapCard | 1 |
| 9 | PieChartCard | 4 |
| 10 | SingleKPICard | 12 |
| 11 | StackedBarChartCard | 4 |
| 16 | StaticBoxCard | 2 |
| 17 | MarkdownCard | 1 |

### 4.3 DashboardGridFilter — Filter Widgets

**Purpose:** Defines filter widgets displayed on a dashboard grid. Each filter references a `DataSet` — the filter widget queries that dataset to populate its options.

| Column | Type | Nullable | Notes |
|---|---|---|---|
| `DashboardGridFilterId` | `uniqueidentifier` | NOT NULL | PK |
| `TransactionId` | `bigint` | NOT NULL | |
| `DashboardGridId` | `uniqueidentifier` | NOT NULL | FK to `DashboardGrid` |
| `DataSet` | `nvarchar(1024)` | NOT NULL | Filter dataset token |
| `IsDeleted` | `bit` | NOT NULL | |
| `DateCreated` | `datetime2` | NOT NULL | |
| `DateUpdated` | `datetime2` | NOT NULL | |
| `SortOrder` | `int` | NOT NULL | Display order within the grid |

---

## 5. Three-Tier Configuration Hierarchy

The database implements a three-level override system for dashboard configuration, palette selection, and navigation grouping:

```
Level 1 — Platform Default (currently unused)
    DashboardConfig           → names/icons for dashboard grids
    DashboardGroupMapping     → maps groups to configs
    DashboardPalette          → 11 system palettes (90 colours)

Level 2 — Organisation Override (active)
    OrganisationDashboardConfig          → 14 rows, 8 orgs, 7 grids
    OrganisationDashboardGroupMapping    → empty (groups not yet used)
    OrganisationDashboardPalette         → 1 seed row ("trocs")
    OrganisationDashboardPaletteColour   → 1 seed colour (#F4A0C3)

Level 3 — Staff Override (unused, schema ready)
    StaffDashboardConfig                 → empty
    StaffDashboardGroupMapping           → empty
    StaffDashboardPalette                → 1 seed row ("trocs_staff")
    StaffDashboardPaletteColour          → 1 seed colour (#F4A0C3)
```

**Resolution logic (from `DashboardGrid_Load` SP):** A grid is accessible to a caller if any of the three config tables has a non-deleted row pointing to that `DashboardGridId` matching the caller's org/staff identity. The grid itself has no org/staff columns — access isolation is entirely managed by the config layer.

### 5.1 OrganisationDashboardConfig

| Column | Type | Nullable | Notes |
|---|---|---|---|
| `OrganisationDashboardConfigId` | `uniqueidentifier` | NOT NULL | PK |
| `TransactionId` | `bigint` | NOT NULL | |
| `DashboardGridId` | `uniqueidentifier` | NOT NULL | Which grid layout |
| `OrganisationId` | `uniqueidentifier` | NOT NULL | Which organisation |
| `Name` | `nvarchar(256)` | NOT NULL | Dashboard display name |
| `IconName` | `nvarchar(254)` | NOT NULL | Material UI icon name (mostly empty) |
| `SortOrder` | `int` | NOT NULL | Navigation order |
| `IsDeleted` | `bit` | NOT NULL | |
| `DateCreated` | `datetime2` | NOT NULL | |
| `DateUpdated` | `datetime2` | NOT NULL | |

**Current assignments (14 rows, 8 orgs):**

| Organisation | Dashboards |
|---|---|
| `C14CF568-...` | Inventory Analysis, Margin Management, Dashboard Demo 1, Dashboard Demo 2, Test Matt Dashboard |
| `8381A215-...` | Dashboard Demo 1, Dashboard Demo 2 |
| `3EBF26FE-...` | Survey Overview, Lifestyle Provision |
| 5 TG Restaurant orgs | Margin Management (each) |

### 5.2 StaffDashboardConfig

Same as `OrganisationDashboardConfig` plus a `StaffId` (`uniqueidentifier`, NOT NULL) column. Currently empty.

### 5.3 DashboardGroup (Navigation Hierarchy)

| Column | Type | Nullable | Notes |
|---|---|---|---|
| `DashboardGroupId` | `uniqueidentifier` | NOT NULL | PK |
| `TransactionId` | `bigint` | NOT NULL | |
| `ParentDashboardGroupId` | `uniqueidentifier` | YES | Self-FK for tree nesting |
| `Name` | `nvarchar(256)` | NOT NULL | Group label |
| `OrganisationId` | `uniqueidentifier` | YES | NULL = platform-wide |
| `StaffId` | `uniqueidentifier` | YES | NULL = org-wide |
| `SortOrder` | `int` | NOT NULL | |
| `IsDeleted` | `bit` | NOT NULL | DEFAULT 0 |
| `DateCreated` | `datetime2` | NOT NULL | |
| `DateUpdated` | `datetime2` | NOT NULL | |

Currently empty. The `DashboardGroup_Load` SP implements visibility scoping: a group is visible if (a) `OrganisationId IS NULL AND StaffId IS NULL` (global), (b) `OrganisationId = caller` (org-wide), or (c) both match (staff-personal).

---

## 6. Palette System

### 6.1 DashboardPalette + DashboardPaletteColour

**Colour format:** `nvarchar(7)` storing CSS `#RRGGBB` hex strings.

**11 system palettes** (all seeded 2026-02-05):

| SortOrder | Name | Colours | Type |
|---|---|---|---|
| 0 | Purple | 8 | Monotonic light-to-dark |
| 10 | Blue | 8 | Monotonic light-to-dark |
| 20 | Cyan | 8 | Monotonic light-to-dark |
| 30 | Green | 8 | Monotonic light-to-dark |
| 40 | Yellow | 8 | Monotonic light-to-dark |
| 50 | Orange | 8 | Monotonic light-to-dark |
| 60 | Red | 8 | Monotonic light-to-dark |
| 70 | Pink | 8 | Monotonic light-to-dark |
| 70 | Blueberry Twilight | 6 | Multi-hue theme |
| 70 | Mango Fusion | 10 | Multi-hue theme |
| 70 | Cheerful Fiesta | 10 | Multi-hue theme |

Each palette's colours are ordered by `SortOrder` in increments of 10 (0, 10, 20, ...). The 8 single-hue palettes progress from lighter to darker shades. The 3 named-theme palettes use distinct, thematically-related hues.

**Sample palette — Blue:**
`#66B2FF` → `#5599E6` → `#4480CC` → `#3367B3` → `#224E99` → `#113580` → `#001C66` → `#072555`

**Known data issue:** Yellow palette has a duplicate colour at positions 60 and 70 (both `#AB6208`).

### 6.2 Override Model

Organisation and staff palette overrides are **full replacements**, not additive modifications. There is no FK from override tables back to the base `DashboardPalette` — each override creates a wholly new palette with its own name and colour list. The front end loads palettes through three separate SPs:

| SP | Scope | Parameters |
|---|---|---|
| `DashboardPalettes_Load` | System defaults | *(none)* |
| `OrganisationDashboardPalettes_Load` | Org overrides | `@OrganisationIdentifier` |
| `StaffDashboardPalettes_Load` | Staff overrides | `@OrganisationIdentifier`, `@StaffIdentifier` |

---

## 7. Stored Procedures

### 7.1 Auto-Generated CRUD (140 procedures)

Each dbo table gets up to 7 auto-generated procedures following the pattern `{Table}_{Operation}_AutoGenerated`:

| Suffix | Operation | Notes |
|---|---|---|
| `_AddEntity_AutoGenerated` | INSERT + return new ID | |
| `_DeleteEntity_AutoGenerated` | Soft-delete (set `IsDeleted=1`) | |
| `_GetEntity_ByIdentifier_AutoGenerated` | SELECT by PK | |
| `_GetList_Default_AutoGenerated` | SELECT all, ordered by TransactionId + PK | |
| `_GetPage_Default_AutoGenerated` | Paginated SELECT (@PageSize 1–1000, @PageNumber) | |
| `_TotalPages_AutoGenerated` | Page count for pagination | |
| `_UpdateEntity_AutoGenerated` | UPDATE by PK | |

### 7.2 Hand-Written Business Logic (8 procedures)

| Procedure | Parameters | Returns | Purpose |
|---|---|---|---|
| `BiConfig_GetEntities_ByOrganisationIdentifier` | `@OrganisationIdentifier`, `@VisualisationIdentifier` | 4 result sets: BiConfig, VisualisationConfig, VisualisationProcedure, VisualisationDataSetMap | Main config load for a card render |
| `Filter_GetEntities_ByDashboardIdentifier` | `@DashboardIdentifier`, `@OrganisationIdentifier`, `@StaffIdentifier` | 2 result sets: BiConfig + DashboardGridFilter | Filter widget data for a dashboard |
| `DashboardGrid_Load` | `@DashboardGridIdentifier`, `@OrganisationIdentifier`, `@StaffIdentifier` | 2 result sets: DashboardGrid + DashboardGridItem | Grid layout + items (checks all 3 config levels) |
| `DashboardGroup_Load` | `@OrganisationId`, `@StaffId` | 4 result sets: visible groups + 3 mapping sets | Navigation group tree with config mapping |
| `OrganisationDashboardConfig_Load` | `@OrganisationIdentifier` | Org dashboard configs | Dashboard list for org |
| `StaffDashboardConfig_Load` | `@OrganisationIdentifier`, `@StaffIdentifier` | Staff dashboard configs | Dashboard list for staff member |
| `DashboardPalettes_Load` | *(none)* | 2 result sets: palettes + colours | System default palettes |
| `OrganisationDashboardPalettes_Load` | `@OrganisationIdentifier` | 2 result sets: org palettes + colours | Org palette overrides |
| `StaffDashboardPalettes_Load` | `@OrganisationIdentifier`, `@StaffIdentifier` | 2 result sets: staff palettes + colours | Staff palette overrides |

### 7.3 Triggers (40 total)

Two triggers per audited table (19 tables × 2 = 38) plus 2 for `AppVersion` and `DashboardGroup`:

| Pattern | Event | Action |
|---|---|---|
| `{Table}_Updated` | AFTER UPDATE | Sets `DateUpdated = SYSUTCDATETIME()` |
| `{Table}_Audit` | AFTER INSERT, UPDATE, DELETE | Writes to `Audit.{Table}` with action code (`I`/`U`/`D`) |

`AppVersion` has only `_Updated` (no audit trigger — excluded from audit schema).

---

## 8. Audit System

### 8.1 Design

Every audited `dbo` table has a mirror in the `Audit` schema with three extra columns prepended:

| Column | Type | Purpose |
|---|---|---|
| `AuditId` | `bigint` (PK, IDENTITY) | Surrogate audit key |
| `AuditAction` | `char(1)` | `I` = Insert, `U` = Update, `D` = Delete |
| `AuditDate` | `datetime2` (DEFAULT `SYSUTCDATETIME()`) | When the change occurred |

**Limitations:**
- **No user identity** is captured — only what changed and when, not who
- **No before/after diff** — for updates, only the post-change state (from `inserted`) is recorded; reconstructing previous state requires comparing consecutive `U` rows by `AuditId`

### 8.2 Audit Row Counts

The difference between audit rows and live rows reveals edit history:

| Table | Live Rows | Audit Rows | Delta (edits/deletes) |
|---|---|---|---|
| DashboardGridItem | 61 | 331 | 270 (heavy iterative editing) |
| VisualisationDataSetMap | 101 | 136 | 35 |
| VisualisationConfig | 65 | 109 | 44 |
| DashboardGridFilter | 28 | 60 | 32 |
| VisualisationProcedure | 16 | 26 | 10 |
| BiConfig | 8 | 10 | 2 |

---

## 9. Migration History (RoundhousE)

The database uses [RoundhousE](https://github.com/chucknorris/roundhouse) for schema migrations.

### 9.1 Deployment Timeline

| Date | Version | Scripts | Key Changes |
|---|---|---|---|
| 2025-12-16 | 1.0.63284 | 37 | Initial DB: schemas, core tables, audit, triggers, SPs |
| 2025-12-30 | 1.0.63466 | — | SP updates |
| 2026-01-07 | 1.0.63514–63628 | — | Multiple SP redeploys (active dev day) |
| 2026-01-12 | 1.0.63728 | — | SP updates |
| 2026-02-05 | 1.0.64705–64715 | 18 | **XMSE-420:** Palette tables + data; **XMSE-820:** DashboardGroup tables |
| 2026-02-10 | 1.0.64841–64927 | — | SP redeploys |
| 2026-02-18 | 1.0.65095 | — | SP updates |
| 2026-02-20 | 1.0.65162 | — | SP updates (most recent) |

### 9.2 Deployment Infrastructure

Two deployment agents run in parallel (blue-green pattern):
- `DEVOPSA\thedaddy`
- `DEVOPSB\thedaddy`

Same version often appears twice (once per agent). GUID-named scripts are "everytime" (always-run) scripts — typically stored procedure definitions redeployed on every release.

### 9.3 Feature Tickets Referenced in Scripts

| Ticket | Feature |
|---|---|
| `DATA-227` | App Version table |
| `XMSE-420` | Palette system (tables, audit, triggers, data, SPs) |
| `XMSE-642` | Column classification |
| `XMSE-820` | Dashboard groups (tables, audit, mappings, SPs) |

---

## 10. Foreign Key Map

```
DashboardGrid ◄──── DashboardConfig.DashboardGridId
    │
    ├──── DashboardGridItem.DashboardGridId
    │         └── VisualisationId ···> VisualisationProcedure.VisualisationId (no FK)
    │         └── DataSet ···········> core.core.VisualisationQueries.DataSetName (cross-system)
    │
    └──── DashboardGridFilter.DashboardGridId

DashboardGroup ◄──── DashboardGroup.ParentDashboardGroupId (self-ref)
    │
    ├──── DashboardGroupMapping(DashboardGroupId, DashboardConfigId)
    │         └──── DashboardConfig.DashboardConfigId
    │
    ├──── OrganisationDashboardGroupMapping(DashboardGroupId, OrganisationDashboardConfigId)
    │         └──── OrganisationDashboardConfig.OrganisationDashboardConfigId
    │
    └──── StaffDashboardGroupMapping(DashboardGroupId, StaffDashboardConfigId)
              └──── StaffDashboardConfig.StaffDashboardConfigId

VisualisationConfig ◄──── VisualisationDataSetMap.VisualisationConfigId

DashboardPalette ◄──── DashboardPaletteColour.DashboardPaletteId
OrganisationDashboardPalette ◄──── OrganisationDashboardPaletteColour.OrganisationDashboardPaletteId
StaffDashboardPalette ◄──── StaffDashboardPaletteColour.StaffDashboardPaletteId

BiConfig (standalone — OrganisationId is not FK-constrained)
AppVersion (standalone — no relationships)
```

**Notable FK gaps (no declared constraint):**
- `OrganisationDashboardConfig.DashboardGridId` → `DashboardGrid` (enforced only at SP level)
- `StaffDashboardConfig.DashboardGridId` → `DashboardGrid` (enforced only at SP level)
- `DashboardGridItem.VisualisationId` → `VisualisationProcedure` (loose integer join)
- `VisualisationConfig.VisualisationId` → `VisualisationProcedure` (no FK)
- `BiConfig.OrganisationId`, `VisualisationConfig.OrganisationId`, `OrganisationDashboardConfig.OrganisationId` → `organisation` microservice DB (cross-database, cannot be FK-constrained)

---

## 11. Data Flow: How a Dashboard Renders

```
1. User opens dashboard
   │
   ├─► OrganisationDashboardConfig_Load(@OrgId)
   │   Returns: list of dashboards (Name, IconName, DashboardGridId) for this org
   │
   ├─► DashboardPalettes_Load() + OrganisationDashboardPalettes_Load(@OrgId)
   │   Returns: system palettes + any org overrides
   │
2. User selects a dashboard
   │
   ├─► DashboardGrid_Load(@GridId, @OrgId, @StaffId)
   │   Returns: grid layout (Container, Spacing, Columns) + items (DataSet, VisualisationId, column spans, SortOrder)
   │
   ├─► Filter_GetEntities_ByDashboardIdentifier(@GridId, @OrgId, @StaffId)
   │   Returns: BiConfig (DbPrefix) + filter datasets for this grid
   │
3. For each DashboardGridItem:
   │
   ├─► BiConfig_GetEntities_ByOrganisationIdentifier(@OrgId, @VisId)
   │   Returns: BiConfig + VisualisationConfig + VisualisationProcedure + DataSetMap
   │   → Resolves: MI database name = {DbPrefix}_XMS_{OrgId}
   │   → Resolves: SP name = VisualisationProcedure.ProcedureName (e.g. core.SingleKPICard)
   │   → Resolves: DataSet = VisualisationDataSetMap.DataSet
   │
   └─► Calls {ProcedureName}(@DataSet, @FilterClause, ...) on MI client database
       → SP looks up QueryTemplate from core.core.VisualisationQueries WHERE DataSetName = @DataSet
       → Executes query, returns result sets to front end
```

---

## 12. Known Issues and Anomalies

| Issue | Details |
|---|---|
| Missing BiConfig for SurveyHero org | `3EBF26FE-...` has VisualisationConfig + OrganisationDashboardConfig but no BiConfig — cannot resolve MI database |
| `VisualisationId` 14 gap | `FilterList` intentionally excluded from VisualisationProcedure (handled separately) |
| `core.StaticBoxCard` not in MI release scripts | VisualisationId 16 exists in UAT microservice but not yet deployed to MI release scripts |
| Misspelled dataset `InvUseAnalisys` | Should be `InvUseAnalysis` — must match exactly in MI |
| Yellow palette duplicate | Positions 60 and 70 both `#AB6208` — likely data entry error |
| Malformed constraint names | `PK_[OrganisationDashboardConfig`, `PK_[StaffDashboardConfig`, `PK_[VisualisationConfig` — stray `[` in names |
| FK naming inconsistency | `FK_OrganisationDashboardPaletteColour_DashboardPaletteId` actually references `OrganisationDashboardPaletteId` |
| FK typo | `FK_DashboardConfigm_DashboardGridId` — extra `m` |
| Redundant predicate in SP | `OrganisationDashboardPalettes_Load` has doubled `IsDeleted = 0` check |
| Survey coverage minimal | Only 2 of 37 survey datasets are wired in the microservice |
