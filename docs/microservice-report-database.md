# Microservice Report Database Reference

> **Source:** UAT environment (`xms-mssql-ne-uat`, Azure SQL Database)
> **Database:** `report`
> **Audited:** 2026-03-11 via MCP read-only inspection
> **Partial update:** 2026-05-18 — dashboard-groups schema is now load-bearing (§5.3, §11).
> **Full re-audit:** 2026-07-29 (second pass, four-agent sweep) — every section re-verified live against UAT. This pass added the migration changelog through 2026-07-15 (§9.1), the palette-selection tier (§6.3), `DomainEventLog` (§3.6), corrected the procedure counts and the `_DeleteEntity` semantics (§7), refreshed §4.1/§4.2/§8.2, and rewrote §12. **Counts are point-in-time.** They have gone stale twice in four months; prefer the catalog queries recorded beside each table over the printed figures, and treat only the semantically load-bearing numbers (16 card types, 11 system palettes) as durable.
> **Purpose:** Dashboard configuration store for the XMS front-end application

## 1. Overview

The `report` database is the **microservice-side configuration store** that drives the XMS BI dashboard front end. It contains no analytical data — that lives in the per-organisation databases on the XMS BI SQL Server Managed Instance. Instead, this database controls:

- **Which organisations** can see which card types (visualisation access control)
- **Which datasets** are wired to which card types per organisation
- **Dashboard layouts** — grid definitions, item placement, responsive breakpoints
- **Colour palettes** — system, organisation and staff palette *definitions*, plus a staff-scoped palette *selection* tier (§6). Note there is no organisation-level selection: an org palette is offered, never applied.
- **Dashboard navigation** — groups, naming, icons, sort order. **As of 2026-05-18 the front end navigates dashboards through `DashboardGroup_Load` rather than the flat config list, so a `*DashboardConfig` row that is not joined to a visible group via the matching `*GroupMapping` table will not render.**

The database bridges the microservice layer and the BI Managed Instance through two key tokens:
1. **`DbPrefix`** (in `BiConfig`) — resolves to the MI database name: `{DbPrefix}_XMS_{OrganisationId}`
2. **`DataSet`** (in `DashboardGridItem`, `DashboardGridFilter`, `VisualisationDataSetMap`) — matches `DataSetName` in `core.core.VisualisationQueries` on the MI

> **Write path (human-run).** All microservice MCP servers are **read-only** — this DB cannot be written via MCP. Report-DB config changes are made through `ms_`-prefixed SQL scripts applied directly to the `report` database by a human. There is no report-DB PowerShell runner yet (unlike the MI-side deployment runners); the scripts are run by hand and must be committed/reviewable.
>
> ⚠️ **The application caches this configuration, and a direct SQL write does not invalidate that cache.** Per the front-end team (2026-07-30): adding data through the **admin tools** clears the cache automatically; a SQL script does not. So a correctly-applied change can appear to have done nothing in the UI for an arbitrarily long time. This is precisely what hid the Growyze organisation palettes for three months — the rows were present and correct from 2026-04-16 but did not surface until the cache was cleared on 2026-07-30. **Before concluding a report-DB change failed, query the tables: if the rows are there, suspect the cache.** Prefer the admin tools for anything they cover.

### Server Details

| Property | Value |
|---|---|
| Server | `xms-mssql-ne-uat` |
| Edition | SQL Azure (Azure SQL Database) |
| Databases on server | 18 (one per microservice domain) |
| Cross-database queries | Not supported (Azure SQL DB limitation) |
| MCP connection | Use **either** `microservice-uat-report` **or** `microservice-uat` (or `-dev` / `-test`) and pass `database='report'` on the `query` call. Both reach the report DB — verified 2026-07-29: `SELECT DB_NAME(), @@SERVERNAME` returns `report`, `xms-mssql-ne-uat`. *(An earlier note claiming `microservice-uat-report` lands in `master` was wrong and has been removed; the entire 2026-07-29 re-audit ran through it.)* All microservice MCP servers are read-only — `execute` is not enabled on any `microservice-*` entry, so this DB cannot be written via MCP. Two tool-level constraints: `--` comments are rejected, and three-part names are rejected (use two-part `Audit.DashboardGroup` with `database='report'`). |

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
| `dbo` | Live configuration data | 25 | 48 | 173 |
| `Audit` | Change history (mirror of dbo) | 23 | 0 | 0 |
| `RoundhousE` | Migration tracking | 3 | 0 | 0 |

### Table Inventory

| Schema | Table | Rows | Purpose |
|---|---|---|---|
| **dbo** | `AppVersion` | 17 | Application deployment version log |
| | `BiConfig` | 18 | Organisation-to-MI-database mapping |
| | `VisualisationProcedure` | 16 | Card type SP registry |
| | `VisualisationConfig` | 190 | Organisation access to card types |
| | `VisualisationDataSetMap` | 761 | Dataset assignments per org+card type |
| | `DashboardGrid` | 75 | Grid layout containers |
| | `DashboardGridItem` | 551 | Cards placed on grids |
| | `DashboardGridFilter` | 145 | Filter widgets on grids |
| | `DashboardConfig` | 0 | Platform-default dashboard naming (still unused) |
| | `DashboardGroup` | 19 | **Navigation group hierarchy — now load-bearing for visibility (see §5.3)** |
| | `DashboardGroupMapping` | 0 | Group ↔ platform-default `DashboardConfig` junction (still unused — `DashboardConfig` is empty) |
| | `DashboardPalette` | 11 | System colour palettes |
| | `DashboardPaletteColour` | 90 | Colours within palettes |
| | `DomainEventLog` | 0 | Append-only domain-event log (EventType/Source/Payload; self-FK `ParentDomainEventLogId` for event causation chains). Empty on UAT as of 2026-07-29. |
| | `OrganisationDashboardConfig` | 86 | Org-scoped dashboard naming/assignment — must be joined to a `DashboardGroup` via `OrganisationDashboardGroupMapping` to render |
| | `OrganisationDashboardGroupMapping` | 86 | **Org group ↔ config junction — required for org dashboard visibility** |
| | `OrganisationDashboardPalette` | 3 | Org palette override |
| | `OrganisationDashboardPaletteColour` | 9 | Org palette colour override |
| | `StaffDashboardConfig` | 0 | Staff-scoped dashboard config (DEV has rows; UAT still empty) |
| | `StaffDashboardGroupMapping` | 0 | **Staff group ↔ config junction — required for staff dashboard visibility** |
| | `StaffDashboardPalette` | 1 | Staff palette override (seed data) |
| | `StaffDashboardPaletteColour` | 1 | Staff palette colour override (seed data) |
| | `StaffDefaultPalette` | 0 | **Palette-*selection* layer** — points a staff member (Org+Staff) at a `PaletteId`. Distinct from the colour-*override* tables above; carries no colours, just a pointer. Empty on UAT as of 2026-07-29. |
| | `StaffDashboardDefaultPalette` | 0 | Palette-selection layer at per-dashboard granularity (+`DashboardGridId`). Empty on UAT as of 2026-07-29. |
| | `StaffDashboardItemDefaultPalette` | 0 | Palette-selection layer at per-card granularity (+`DashboardGridId` +`DashboardGridItemId`). Empty on UAT as of 2026-07-29. |
| **Audit** | *(23 tables)* | — | Mirror of each dbo table except AppVersion and `DomainEventLog` |
| **RoundhousE** | `Version` | 44 | Migration version history |
| | `ScriptsRun` | 97 | Deployed script log |
| | `ScriptsRunErrors` | 0 | Script error log — **no migration has ever failed** |

### Common Column Patterns

Every dbo table **except `AppVersion` and `DomainEventLog`** follows a uniform pattern:

| Column | Type | Purpose |
|---|---|---|
| `{Table}Id` | `uniqueidentifier` (DEFAULT `NEWSEQUENTIALID()`) | Primary key — **never specify it**; capture generated values via `OUTPUT inserted.{PK} INTO @tableVar`. Holds for 21 of 25 tables. **Two exception classes:** `AppVersion.AppVersionId` is `int IDENTITY`, and the three `*GroupMapping` junctions have **no surrogate PK at all** (composite natural key on the two GUID FK columns) — for those you must supply both columns explicitly, which inverts the rule for exactly the tables dashboard-visibility work requires you to write to. |
| `TransactionId` | `bigint IDENTITY` | Optimistic concurrency / event sequence (clustered index, auto-incremented). Never include it in an INSERT column list. Present on 24 of 25 dbo tables — `AppVersion` has no `TransactionId`. |
| `IsDeleted` | `bit NOT NULL` (default varies) | Soft-delete flag. **Always set it explicitly to `0` in INSERT statements** — safe everywhere, required in most places. Default constraints are inconsistent: the four XMSE-820-era tables — `DashboardGroup`, `DashboardGroupMapping`, `OrganisationDashboardGroupMapping`, `StaffDashboardGroupMapping` — carry `DEFAULT ((0))`; the other 20 have **no** default, so an omitted `IsDeleted` fails the NOT NULL constraint. `AppVersion` and `DomainEventLog` have no `IsDeleted` column at all. **"Never physically deleted" is NOT true** — the auto-generated `_DeleteEntity` procedures issue a hard `DELETE`; see §7.1. |
| `DateCreated` | `datetime2` (DEFAULT `SYSUTCDATETIME()`) | UTC creation timestamp |
| `DateUpdated` | `datetime2` (DEFAULT `SYSUTCDATETIME()`) | UTC last-update (maintained by `_Updated` trigger) |

### Indexing Strategy

All tables use a dual-index pattern:

| Index | Type | Key |
|---|---|---|
| `CX_{Table}_TransactionId` | **Clustered**, unique | `TransactionId` — physical row order by write sequence |
| `PK_{Table}` | Non-clustered, unique | `{Table}Id` (GUID) — logical primary key |

This design optimises for append-heavy workloads: new rows are physically appended in write order (ascending bigint), while GUID lookups use a secondary index.

**Exceptions to the dual-index pattern:**

| Table | Deviation |
|---|---|
| `VisualisationProcedure` | Third unique index `UQ_VisualisationProcedure_SingleActive`, keyed on **`(VisualisationId, IsDeleted)`** — that composite is the mechanism enforcing "one active procedure per `VisualisationId`" while still permitting soft-deleted history rows. |
| `AppVersion` | Single **clustered** `PK_AppVersion_AppVersionId`; no `CX_*_TransactionId` (it has no `TransactionId`). |
| `DomainEventLog` | 5 indexes, two of them **filtered**: `UQ_DomainEventLog_EventId_Root` (unique, `WHERE ParentDomainEventLogId IS NULL`) and `IX_DomainEventLog_ParentDomainEventLogId` (`WHERE … IS NOT NULL`), plus `IX_DomainEventLog_EventType_Timestamp`. See §3.6. |
| `StaffDefaultPalette`, `StaffDashboardDefaultPalette`, `StaffDashboardItemDefaultPalette` | Each carries a third **unique** index on its natural key (see §6.3) — this is what makes their `_Upsert` procedures idempotent. |

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

**Current data (18 organisations as of 2026-07-29 — the sample rows below are from the March audit and no longer list every org):**

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

**Resolved (2026-07-29):** organisation `3EBF26FE-...` (NeighboursSurvey/SurveyHero) previously had `VisualisationConfig` and `OrganisationDashboardConfig` rows but **no** `BiConfig` entry. It now has one (`DbPrefix` `20251202`) and is in fact UAT's richest org — 16 dashboards and 17 live `VisualisationConfig` rows, the only org entitled to all 17 card types. Left-joining all 18 `VisualisationConfig` orgs to `BiConfig` now returns zero unresolved orgs.

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
- `core.StaticBoxCard` (id 16) is now present in the MI release scripts (`releases/v1.0-baseline/8_Deployment_Objects_Records.sql` and `8_VisualisationQueries.sql`) — the earlier "UAT only" gap is closed.
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

**Summary:** 190 rows, 18 distinct organisations (as of 2026-07-29). All `ActiveUntil` values are NULL (temporal expiry has never been used).

**Entitlement practice — a broad grant, independent of dashboard usage.** Orgs are granted card types wholesale, not per what their dashboards currently render. Live grant sizes range from 6 to 17 distinct card types per org: one org has all 17, one has 15 (ids `1–13, 16, 17`), six have 13, and the five TG Restaurant orgs (`DbPrefix=20260129`) each have 6 (ids `2, 9, 10, 11, 16, 17`). A card type appearing in `VisualisationConfig` for an org is an entitlement, not evidence that any dashboard uses it.

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

**Not a render gate.** `VisualisationDataSetMap` governs the *available-dataset roster* surfaced in the config/authoring UI — it does **not** gate whether a card renders. A `DashboardGridItem` renders off its own `DataSet` + card SP even when that dataset is absent from the org's map (live-proven). House practice still keeps the map complete for each org, but a missing map row is a config-UI gap, not a broken card.

**Summary (measured 2026-07-29):** 761 rows total, **742 live**, **366 distinct live dataset names**. Domain breakdown:

| Domain | Distinct live datasets | Examples |
|---|---|---|
| Survey (`*Survey*`) | **115** | `SurveyDistChallenge*`, `SurveyDistEnvironment*`, `SurveyDistLifestyle*`, `Survey*Radar` |
| Inventory (`Inv*`) | 35 | `InvTheoMargin`, `InvCountVariance`, `InvNetSales`, `InvWasteCost`, `InvTop20Variance` |
| RedLion (bespoke) | 23 | `RedLionNetSales`, `RedLionCatMix`, `RedLionProdAttach`, `RedLionWeeklyPattern` |
| MargeBrut (bespoke) | 9 | `MargeBrutGrid`, `MargeBrutCostRatioKPI`, `MargeBrutConsumptionMix` |
| Sales/POS and other | remainder | `NetSales`, `NetSalesByHour`, `ProductMargins`, `Discounts`, `DiscountPerc` |

Reproduce with:
```sql
SELECT COUNT(*) AS live_rows, COUNT(DISTINCT DataSet) AS distinct_datasets
FROM dbo.VisualisationDataSetMap WHERE IsDeleted = 0;
```

⚠️ **Filter `IsDeleted = 0` in any count.** Soft-delete debris is large enough to distort totals by 10–25% on the busier tables (`DashboardGridItem` 551 rows / 490 live; `DashboardGridFilter` 145 / 109).

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

**Current versions (2026-07-29):** 17 entries. ⚠️ **The build counter was reset in April 2026 and version strings are no longer monotonic** — the sequence runs `1.0.0` (2025-12-16) … `1.0.64927` (2026-02-10) → **`1.0.18`** (2026-04-09) → `1.0.30` → `1.0.34` → `1.0.38` → `1.0.45` → `1.0.51` → `1.0.54` → `1.0.59` (2026-07-15, latest). Do not use `Number` for ordering or as a freshness signal — sort by `DateCreated`, or use `RoundhousE.ScriptsRun` (§9).

### 3.6 DomainEventLog — Domain Event Inbox (XMSE-1323, added 2026-06-23)

**Purpose:** Append-only domain-event log with idempotent-inbox semantics. Deployed 2026-06-23 (RoundhousE scripts `071`–`073`); **0 rows on UAT as of 2026-07-29** — the capability exists but nothing writes to it yet.

| Column | Type | Nullable | Notes |
|---|---|---|---|
| `DomainEventLogId` | `uniqueidentifier` | NOT NULL | PK, DEFAULT `NEWSEQUENTIALID()` |
| `TransactionId` | `bigint` | NOT NULL | IDENTITY |
| `EventId` | `uniqueidentifier` | NOT NULL | Source event identity — the idempotency key |
| `EventType` | `nvarchar(128)` | NOT NULL | |
| `Source` | `nvarchar(128)` | NOT NULL | Emitting service |
| `Timestamp` | `datetime2(7)` | NOT NULL | Event time (as reported by the source) |
| `CorrelationId` | `nvarchar(128)` | YES | |
| `OrganisationId` | `uniqueidentifier` | YES | |
| `Version` | `nvarchar(32)` | NOT NULL | Event schema version |
| `Payload` | `nvarchar(max)` | NOT NULL | Serialised event body |
| `LastUpdatedByUserId` | `uniqueidentifier` | YES | **First user-identity column anywhere in this database** |
| `ConcurrencyStamp` | `uniqueidentifier` | NOT NULL | DEFAULT `NEWID()` |
| `ParentDomainEventLogId` | `uniqueidentifier` | YES | Self-FK — duplicate arrivals chain to the root row |
| `DateCreated` / `DateUpdated` | `datetime2(7)` | NOT NULL | DEFAULT `SYSUTCDATETIME()` |

**Breaks two documented invariants:** it has **no `IsDeleted`** column, and **no `Audit` mirror** (only a `_Updated` trigger, no `_Audit`). The audit-schema arithmetic still balances: 25 dbo − `AppVersion` − `DomainEventLog` = 23 Audit tables.

**`DomainEventLog_Create` is an idempotent inbox, not a plain insert.** First arrival of an `EventId` inserts a root row (`ParentDomainEventLogId` NULL) and returns `IsNew = 1`; a duplicate `EventId` inserts a child row pointing at the root and returns `IsNew = 0`. Uniqueness is enforced by the filtered index `UQ_DomainEventLog_EventId_Root`, and a `TRY/CATCH` on errors 2601/2627 handles the insert race. Returns `(Id, IsNew)`. There is **no CRUD set** for this table — `_Create` is the only entry point.

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

**75 grids** as of 2026-07-29 (all live), serving 86 org-dashboard rows. The March audit's 7-grid table is long obsolete and is not reproduced here — a named inventory goes stale within weeks. Query it instead:

```sql
SELECT g.DashboardGridId, c.Name AS dashboard_name, c.OrganisationId,
       (SELECT COUNT(*) FROM dbo.DashboardGridItem   i WHERE i.DashboardGridId = g.DashboardGridId AND i.IsDeleted = 0) AS live_items,
       (SELECT COUNT(*) FROM dbo.DashboardGridFilter f WHERE f.DashboardGridId = g.DashboardGridId AND f.IsDeleted = 0) AS live_filters
FROM dbo.DashboardGrid g
LEFT JOIN dbo.OrganisationDashboardConfig c
       ON c.DashboardGridId = g.DashboardGridId AND c.IsDeleted = 0
WHERE g.IsDeleted = 0 ORDER BY c.OrganisationId, c.SortOrder;
```

**Grids are org-less and genuinely shared.** `DashboardGrid` has no `OrganisationId`, and sharing is real rather than theoretical: grid `050FCDB8-…` ("Margin Management") is referenced by **6 different organisations**, and four Growyze grids are shared by 2 orgs each. Editing a grid therefore changes every dashboard pointing at it, across organisations — check the config-side fan-out before altering items.

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

**Card types in active use (490 live items, measured 2026-07-29):**

| VisualisationId | Card Type | Live Items |
|---|---|---|
| 10 | SingleKPICard | 149 |
| 1 | BarChartCard | 130 |
| 3 | CustomDataGrid | 48 |
| 2 | CombinedChartCard | 44 |
| 8 | MultiLineChartCard | 40 |
| 11 | StackedBarChartCard | 32 |
| 9 | PieChartCard | 20 |
| 6 | HeatmapCard | 13 |
| 15 | RadarChartCard | 6 |
| 7 | LineChartCard | 3 |
| 4 | CustomGroupedDataGrid | 2 |
| 16 | StaticBoxCard | 2 |
| 17 | MarkdownCard | 1 |

`SingleKPICard` and `BarChartCard` account for 57% of all placed cards. Ids 5 (`CustomPinnedDataGrid`), 12 (`StatCard`) and 13 (`TreeViewCard`) are registered but unused on UAT. Reproduce with:
```sql
SELECT i.VisualisationId, p.ProcedureName, COUNT(*) AS live_items
FROM dbo.DashboardGridItem i
LEFT JOIN dbo.VisualisationProcedure p
  ON p.VisualisationId = i.VisualisationId AND p.IsDeleted = 0
WHERE i.IsDeleted = 0 GROUP BY i.VisualisationId, p.ProcedureName ORDER BY live_items DESC;
```

### 4.3 DashboardGridFilter — Filter Widgets

**Purpose:** Defines filter widgets displayed on a dashboard grid. Each filter references a `DataSet` — the filter widget queries that dataset to populate its options.

**Loaded by `Filter_GetEntities_ByDashboardIdentifier`, not `DashboardGrid_Load`.** Filters are served by a separate SP (verified present in `sys.procedures`) keyed on the dashboard/grid identifier; `DashboardGrid_Load` returns only the grid layout and its items. See §11 for the full render sequence.

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
Level 1 — Platform Default (unused — both tables 0 rows as of 2026-07-29)
    DashboardConfig           → names/icons for dashboard grids (0 rows)
    DashboardGroupMapping     → maps groups to platform-default configs (0 rows)
    DashboardPalette          → 11 system palettes (90 colours)

Level 2 — Organisation Override (active)
    OrganisationDashboardConfig          → 86 rows, 18 orgs (as of 2026-07-29)
    OrganisationDashboardGroupMapping    → 86 rows — REQUIRED for dashboard visibility (see §5.3)
    OrganisationDashboardPalette         → 3 rows
    OrganisationDashboardPaletteColour   → 9 rows

Level 3 — Staff Override (live on DEV, empty on UAT)
    StaffDashboardConfig                 → 11 rows on DEV, 0 on UAT
    StaffDashboardGroupMapping           → REQUIRED for staff dashboard visibility (see §5.3)
    StaffDashboardPalette                → 1 seed row ("trocs_staff")
    StaffDashboardPaletteColour          → 1 seed colour (#F4A0C3)
    StaffDefaultPalette / StaffDashboardDefaultPalette /
    StaffDashboardItemDefaultPalette     → palette *selection* tier, 0 rows (see §6.3)
```

> ⚠️ **Levels 1 and 3 are currently unwritable — audit-trigger regression (verified 2026-07-29).**
> `Audit.DashboardConfig` and `Audit.StaffDashboardConfig` both have `DashboardGridId`, `IconName` and `SortOrder` as `NOT NULL` with no default (added by the 2026-04-09 rebuild), but their audit triggers were never updated to populate them: `DashboardConfig_Audit` (835 chars) and `StaffDashboardConfig_Audit` (970) reference none of the three columns. Any INSERT or UPDATE against `dbo.DashboardConfig` or `dbo.StaffDashboardConfig` therefore fails inside the trigger on a NOT NULL violation.
> `OrganisationDashboardConfig_Audit` (1232 chars) *was* updated, which is why the organisation tier works.
> **Both tables being empty is a symptom, not a design choice** — the platform-default and staff tiers cannot be populated until the two triggers are fixed. Do not plan work on either tier before then.
> Detect with: `SELECT name, LEN(definition) FROM sys.triggers t JOIN sys.sql_modules m ON m.object_id = t.object_id WHERE name LIKE '%Config_Audit'`.

**Resolution logic (two layers, both gating):**
1. **Group visibility (`DashboardGroup_Load` SP):** A `DashboardGroup` is visible to a caller if `(OrganisationId IS NULL AND StaffId IS NULL)` (platform-wide), `(OrganisationId = caller AND StaffId IS NULL)` (org-wide), or both match (staff-personal). Dashboards are returned only via the matching `*GroupMapping` join.
2. **Grid access (`DashboardGrid_Load` SP):** A grid is accessible if any of the three config tables has a non-deleted row pointing to that `DashboardGridId` matching the caller's org/staff identity. The grid itself has no org/staff columns — access isolation is entirely managed by the config layer.

A dashboard must satisfy **both** layers to render: its `*Config` row must exist (Layer 2) **and** it must be joined to a visible group via the matching `*GroupMapping` (Layer 1).

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

**Current assignments (86 rows, 18 orgs as of 2026-07-29 — the sample below is from the March audit and no longer reflects every assignment):**

| Organisation | Dashboards |
|---|---|
| `C14CF568-...` | Inventory Analysis, Margin Management, Dashboard Demo 1, Dashboard Demo 2, Test Matt Dashboard |
| `8381A215-...` | Dashboard Demo 1, Dashboard Demo 2 |
| `3EBF26FE-...` | Survey Overview, Lifestyle Provision |
| 5 TG Restaurant orgs | Margin Management (each) |

### 5.2 StaffDashboardConfig

Same columns as `OrganisationDashboardConfig` plus `StaffId` (`uniqueidentifier`, NOT NULL). Currently empty — and **unwritable**, see the audit-trigger warning in §5.

**Positional gotcha for INSERT statements without a column list.** `StaffId` is **third** in ordinal position (`DashboardGridId, OrganisationId, StaffId, Name, …`), not appended at the end. Separately, the 2026-04-09 rebuild *appended* rather than inserted columns, so in all three config tables (`DashboardConfig`, `OrganisationDashboardConfig`, `StaffDashboardConfig`) **`IconName` and `SortOrder` sit after `DateUpdated`**, not in the logical position this document lists them. Always name your columns explicitly.

### 5.3 DashboardGroup (Navigation Hierarchy) — load-bearing as of 2026-05-18

| Column | Type | Nullable | Notes |
|---|---|---|---|
| `DashboardGroupId` | `uniqueidentifier` | NOT NULL | PK, DEFAULT `NEWSEQUENTIALID()` |
| `TransactionId` | `bigint` | NOT NULL | IDENTITY |
| `ParentDashboardGroupId` | `uniqueidentifier` | YES | Self-FK for tree nesting |
| `Name` | `nvarchar(256)` | NOT NULL | Group label |
| `OrganisationId` | `uniqueidentifier` | YES | NULL = platform-wide |
| `StaffId` | `uniqueidentifier` | YES | NULL = org-wide (only valid alongside an `OrganisationId`) |
| `SortOrder` | `int` | NOT NULL | **No default** — must be supplied explicitly. (Earlier revisions of this document claimed `DEFAULT 0`; that is wrong and it masked the `_AddEntity` bug below.) |
| `IsDeleted` | `bit` | NOT NULL | DEFAULT 0 |
| `DateCreated` | `datetime2` | NOT NULL | DEFAULT `SYSUTCDATETIME()` |
| `DateUpdated` | `datetime2` | NOT NULL | DEFAULT `SYSUTCDATETIME()` |

**Visibility scoping (`DashboardGroup_Load`):** a group is returned to a `(@OrganisationId, @StaffId)` call when **one** of:
- `OrganisationId IS NULL AND StaffId IS NULL` — platform-wide
- `OrganisationId = caller AND StaffId IS NULL` — org-wide
- `OrganisationId = caller AND StaffId = caller` — staff-personal

`DashboardGroup_Load` returns **four result sets**: visible groups (into `#VisibleGroups`), then three mapping sets `INNER JOIN`ing the visible groups to `DashboardConfig` / `OrganisationDashboardConfig` / `StaffDashboardConfig` respectively. **A dashboard config row that is not joined to a visible group is absent from the payload entirely** — not merely unnavigable — with no error or warning.

**Groups gate discovery, not access.** `DashboardGrid_Load` performs no group check, so a dashboard omitted from every group is still reachable by direct grid URL. Group membership controls the navigation tree only; org isolation is enforced separately in the config layer (Layer 2).

**Two defects in `DashboardGroup_Load` (verified 2026-07-29 — both undocumented before this pass):**

1. **Soft-deleting a mapping does nothing.** All three mapping result sets filter `{config}.IsDeleted = 0` but **never the mapping's own `IsDeleted`**. So `DashboardGroupMapping_Delete`, or `OrganisationDashboardGroupMapping_UpdateEntity @IsDeleted = 1`, leave the dashboard fully visible. To actually remove a dashboard from a group you must hard-`DELETE` the junction row, soft-delete the group, or soft-delete the config. Corollary: the "revive" branch in the population script (`WHEN MATCHED AND tgt.IsDeleted = 1 THEN UPDATE SET IsDeleted = 0`) is a no-op in visibility terms — those rows were never hidden.
2. **A platform-wide group is a cross-org leak vector.** The org-tier result set filters `odc.IsDeleted = 0` but **not** `odc.OrganisationId = @OrganisationId`. Mapping one org's dashboard into a group with `OrganisationId IS NULL` therefore surfaces its name and grid id in *every* org's navigation. Because `DashboardGrid_Load` *is* org-scoped, the victim sees a visible-but-broken nav entry rather than another org's data. Zero such rows exist today and nothing prevents them.

**Unreachable scope combination.** A `DashboardGroup` row with `StaffId` set but `OrganisationId` NULL matches no branch of the predicate and is silently invisible to everyone. No constraint prevents it; 0 rows currently.

**Nesting is built but unexercised.** `ParentDashboardGroupId` exists, is returned by the SP, and has **0 non-NULL rows** — the tree is entirely flat on UAT. There is no cycle detection, so a cyclic parent chain would be accepted and handed to the client.

**No auto-defaulting.** Because the platform-default tier (Level 1: `DashboardConfig` + `DashboardGroupMapping`) is empty, a newly provisioned org inherits **no** dashboards. It gets dashboards only through explicit per-org config (`OrganisationDashboardConfig`) plus the matching group mapping (`OrganisationDashboardGroupMapping`) — there is no platform-wide default that appears automatically.

**Critical operational consequence:** when provisioning a new organisation (or after promoting dashboards from one environment to another), an `OrganisationDashboardConfig` row alone is insufficient — a corresponding `DashboardGroup` + `OrganisationDashboardGroupMapping` pair must also exist. The minimum-viable provisioning shape is one root-level group per org (with `OrganisationId` set, `StaffId` NULL) containing every dashboard for that org. See `ClaudeDevelopment/microservice-report/01_populate_uat_dashboard_groups.sql` for the reference idempotent population pattern.

**Three mapping tables (all composite-PK junctions, all required for the matching `*Config` tier to render):**

| Mapping table | Joins `DashboardGroup` to | Required when |
|---|---|---|
| `DashboardGroupMapping` | `DashboardConfig` | Using platform-default dashboards (currently no rows) |
| `OrganisationDashboardGroupMapping` | `OrganisationDashboardConfig` | Using org-scoped dashboards (most common) |
| `StaffDashboardGroupMapping` | `StaffDashboardConfig` | Using staff-personal dashboards |

Each mapping table has the same column shape: `(DashboardGroupId, {Config}Id, TransactionId IDENTITY, IsDeleted, DateCreated, DateUpdated)`. Composite PK on the two GUID columns — **no surrogate PK**, so both GUIDs must be supplied explicitly.

**Correction (2026-07-29): the junctions have no `_AddEntity`, but `_UpdateEntity` is NOT an upsert.** Earlier revisions of this document implied upsert semantics; that is wrong on two counts. `*_UpdateEntity` is a plain `UPDATE` — it cannot insert a missing row — and it **requires `@DateCreated`, overwriting the stored value**, so round-trip the existing timestamp or you lose provenance. A genuine upsert exists only in `DashboardGroupMapping_Create` (`IF EXISTS … UPDATE IsDeleted = 0 ELSE INSERT`), and there is **no equivalent for the Organisation or Staff junctions** — for those, hand-write a `MERGE` on the composite key, following `ClaudeDevelopment/microservice-report/01_populate_uat_dashboard_groups.sql`.

**Creating a group + dashboard, in order.** FKs are `NO_ACTION`, so parents first; never specify `{Table}Id` or `TransactionId`; set `IsDeleted = 0` explicitly:

```sql
DECLARE @grid TABLE (DashboardGridId uniqueidentifier);
DECLARE @cfg  TABLE (OrganisationDashboardConfigId uniqueidentifier);
DECLARE @grp  TABLE (DashboardGroupId uniqueidentifier);

INSERT dbo.DashboardGrid (Container, Spacing, [Columns], IsDeleted)
OUTPUT inserted.DashboardGridId INTO @grid VALUES (1, 2, 12, 0);

INSERT dbo.OrganisationDashboardConfig (DashboardGridId, OrganisationId, [Name], IconName, SortOrder, IsDeleted)
OUTPUT inserted.OrganisationDashboardConfigId INTO @cfg
SELECT g.DashboardGridId, @OrgId, N'Cost & Margins', N'', 10, 0 FROM @grid g;

INSERT dbo.DashboardGroup (ParentDashboardGroupId, [Name], OrganisationId, StaffId, SortOrder, IsDeleted)
OUTPUT inserted.DashboardGroupId INTO @grp
VALUES (NULL, N'Margins', @OrgId, NULL, 10, 0);

INSERT dbo.OrganisationDashboardGroupMapping (DashboardGroupId, OrganisationDashboardConfigId, IsDeleted)
SELECT gr.DashboardGroupId, c.OrganisationDashboardConfigId FROM @grp gr, @cfg c;
```

The final junction INSERT is the step most often forgotten — without it the dashboard is invisible. For the group itself prefer `dbo.DashboardGroup_Create @Name, @SortOrder, @OrganisationId`; **do not use `DashboardGroup_AddEntity`, which always throws** (see §7.1).

**Ordering ownership — split across three levels.** Groups order by `DashboardGroup.SortOrder`; **dashboards within a group order by `{Organisation|Staff}DashboardConfig.SortOrder`**, because the junctions carry no `SortOrder` column (position is a property of the dashboard, not of its membership); cards and filters order by `DashboardGridItem.SortOrder` / `DashboardGridFilter.SortOrder`. None of these is unique-constrained and `DashboardGroup_Load` has **no `ORDER BY` at all** — it returns `SortOrder` as a column and leaves sorting to the client. Collisions already exist on UAT (4 groups have tied dashboard positions, 9 grids have tied item positions), so tie-break behaviour is whatever the front end happens to do.

---

## 6. Palette System

> **The palette system is 9 tables, not 2, and it separates *defining* a palette from *selecting* one.** §6.1–6.2 cover definition (3 sibling tier pairs); §6.3 covers selection (3 staff-scoped tables).
>
> **Read §6.3 before doing any palette work.** Definitions are consumed correctly — an org palette does appear in the UI picker — but **there is no default and no persistence**: a palette must be picked by hand each session, and nothing can be set as an organisation's default. The picker's own default (`Rainbow`) is hardcoded in the client and is not in this database. So **defining a palette makes it selectable, not applied.**

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

**Colours map to chart series by position only.** `SortOrder ASC` is the series order — there are no semantic slots (no "positive"/"negative"/"axis"), no keys, and no mapping to dataset values. `Colour` is `nvarchar(7)`, so the column physically cannot hold `#RGB`, 8-digit alpha, or `rgb()` notation.

**Palette length is not fixed** — 6, 8 and 10 all occur among the system palettes, and the bespoke org palettes have only 4 (§6.2). A card requesting more series than its palette provides must wrap or generate colours; that behaviour lives in the front end, not here.

**Known data issues:**
- Yellow has a duplicate colour at positions 60 and 70 (both `#AB6208`) — 8 colours, 7 distinct. All other palettes have distinct = total.
- `DashboardPalette.SortOrder` is **not unique**: Pink, Blueberry Twilight, Mango Fusion and Cheerful Fiesta all sit at 70, so their relative order in the picker is non-deterministic. None of the palette `_Load` procedures has an `ORDER BY` — the client must sort.
- Purple is described as "monotonic light-to-dark", which is accurate, but its actual range (`#577EE3` … `#091159`) is blue-violet and reads as a second blue ramp beside Blue. Worth knowing when picking a default.

### 6.2 Tier Model (the "override" tables are siblings, not overrides)

The three tiers are **siblings, not overrides** — "override" is a misnomer inherited from the table names. There is no FK from the org/staff tables back to `DashboardPalette`, no inheritance, and no per-colour patching. An organisation palette is a wholly independent palette that happens to be visible to one organisation. **"Bespoke" means nothing more than: a row exists in `OrganisationDashboardPalette` carrying your `OrganisationId`.** Nothing marks a palette as system vs custom beyond which table it lives in.

| Tier | Palette table | Owner columns | Colour table | Rows (2026-07-29) |
|---|---|---|---|---|
| System | `DashboardPalette` | *(none — global)* | `DashboardPaletteColour` | 11 / 90 |
| Organisation | `OrganisationDashboardPalette` | `OrganisationId` | `OrganisationDashboardPaletteColour` | 3 / 9 |
| Staff | `StaffDashboardPalette` | `OrganisationId` + `StaffId` | `StaffDashboardPaletteColour` | 1 / 1 |

**Availability is not a precedence.** The front end calls all three procedures and receives three independent lists; each filters strictly on its own scope, and **no procedure merges, ranks, deduplicates or shadows**. A system "Blue" and an org "Blue" both appear. Any precedence between the lists lives entirely in the client.

| SP | Scope | Parameters |
|---|---|---|
| `DashboardPalettes_Load` | System defaults | *(none)* |
| `OrganisationDashboardPalettes_Load` | Org palettes | `@OrganisationIdentifier` |
| `StaffDashboardPalettes_Load` | Staff palettes | `@OrganisationIdentifier`, `@StaffIdentifier` |

Each returns 2 result sets (palettes, then colours).

**The three bespoke org palettes currently on UAT:**

| Palette | OrganisationId | Colours (by `SortOrder`) |
|---|---|---|
| `Growyze` | `94A4B719-…` (Padel Social) | `#000055`, `#34DBD1`, `#FC3762`, `#F3F3FF` |
| `Growyze` | `7B50D717-…` (Dirty Sixth) | `#000055`, `#34DBD1`, `#FC3762`, `#F3F3FF` |
| `trocs` | `61376EF0-…` | `#F4A0C3` (single colour) |

Deployed 2026-04-16 from `ClaudeDevelopment/integrations/Growyze/growyze_org_palette.sql`. Two things to note: **the Growyze brand palette is duplicated per-org, not shared** — the org tier has no shared-palette concept, so every Growyze client needs its own copy; and **both bespoke palettes carry only 4 colours** against system palettes of 6–10, so a many-series card will exhaust them. The `trocs` palette (and the `trocs_staff` staff palette) are 2026-02-05 seed debris — their orgs have no `BiConfig`, no groups and no dashboards.

**Creating a bespoke org palette.** Parent first, then colours; never specify the PK or `TransactionId`; pass `IsDeleted = 0` explicitly:

```sql
DECLARE @PaletteId TABLE (Id uniqueidentifier);

INSERT INTO dbo.OrganisationDashboardPalette (OrganisationId, Name, IsDeleted, SortOrder)
OUTPUT inserted.OrganisationDashboardPaletteId INTO @PaletteId
VALUES (N'<org-guid>', N'<Palette Name>', 0, 0);

DECLARE @Id uniqueidentifier = (SELECT Id FROM @PaletteId);

INSERT INTO dbo.OrganisationDashboardPaletteColour (OrganisationDashboardPaletteId, Colour, IsDeleted, SortOrder)
VALUES (@Id, N'#000055', 0, 0), (@Id, N'#34DBD1', 0, 10),
       (@Id, N'#FC3762', 0, 20), (@Id, N'#F3F3FF', 0, 30);
```

**Nothing enforces one palette per org** — there is no unique constraint on `(OrganisationId, Name)`, so re-running a provisioning script duplicates the palette and both copies appear in the picker. The committed `growyze_org_palette.sql` looks the parent up by name rather than using `OUTPUT`, which is not idempotent; prefer the `OUTPUT` form above. The FK is `NO_ACTION` with no cascade, so colours must be cleaned up manually.

### 6.3 Palette Selection Tier (added 2026-04-09 / 2026-04-29)

Three tables record **which** palette has been chosen, at three granularities. All were deployed by RoundhousE (scripts `060`–`068`) and are **empty on UAT as of 2026-07-29** — the feature is deployed but unexercised, so no behaviour here has been validated against real data.

| Table | Deployed | Business key (unique index) | Extra column |
|---|---|---|---|
| `StaffDefaultPalette` | 2026-04-09 | `(OrganisationId, StaffId)` | — |
| `StaffDashboardDefaultPalette` | 2026-04-09 | `(OrganisationId, StaffId, DashboardGridId)` | `DashboardGridId` |
| `StaffDashboardItemDefaultPalette` | 2026-04-29 | `(OrganisationId, StaffId, DashboardGridId, DashboardGridItemId)` | + `DashboardGridItemId` — a **per-card** palette override |

Each has `_Load` and `_Upsert` only (`MERGE` on the natural key) — **no 7-procedure CRUD set**. Resolution is narrowest-wins, and is applied **by the client, not in SQL**: each `_Load` returns bare keys plus `PaletteId`, and no procedure joins them or applies `COALESCE`.

```
StaffDashboardItemDefaultPalette   (org + staff + grid + item)   most specific
  ↓ StaffDashboardDefaultPalette   (org + staff + grid)
  ↓ StaffDefaultPalette            (org + staff)
  ↓ client-side hardcoded default
```

> ⚠️⚠️ **No default-palette capability was ever built, and selection is not persisted — established with the front-end team 2026-07-30.** In Ian Hamlin's words: *"I dont think we added a default? Just the ability to add palettes — you can add system, org or staff palettes."*
>
> To be precise about what *does* work, verified in the live UI:
> - **Display works at all three tiers.** The palette picker groups palettes as `Default` / `Core` / `Organisation`, and an org palette appears correctly under `Organisation`. The FE calls all three `_Load` procedures and scopes them properly. (A stale cache was why a palette added in April did not appear until the cache was cleared — that was a caching bug, not a missing feature.)
> - **Applying a palette works client-side.** Selecting one immediately re-renders the cards in its colours.
> - **Nothing is saved.** These three tables remain at 0 live and 0 audit rows after a session in which a palette was selected — so a choice is at best session-scoped, and there is no org-wide default at all.
> - **The picker's `Default` entry (`Rainbow`) does not exist in this database.** Card colours default to a hardcoded client-side palette, which means the `DashboardPalette` store is unused until a user explicitly picks something.
>
> **Practical consequence: defining a bespoke palette makes it selectable, not applied.** Do not write rows to these tables expecting an effect — nothing reads them yet. Tracked as ledger **O26**, which recommends the smallest fix: have the FE start from the org's palette instead of `Rainbow` when the org has one. Because the client already renders arbitrary palettes and already identifies the org's palette, that is a defaulting change rather than new theming work.

> ⚠️ **There is no organisation-level selection table. All three selection tables have `StaffId NOT NULL`.**
> Defining an `OrganisationDashboardPalette` row makes a bespoke palette *available* in that org's picker — it does **not** apply it. A palette choice can only be persisted per staff member.
> Consequence: Padel Social and Dirty Sixth each have a Growyze-branded palette defined and **zero rows in any selection table**. Unless the front end special-cases "this org has a bespoke palette, use it", those brand colours are not rendering by default for anyone. Verify with the front-end team before promising a client branded defaults — the schema offers nowhere to store an org-wide default.

> ⚠️ **`PaletteId` is an untyped GUID with no FK and no discriminator.** It may reference `DashboardPaletteId`, `OrganisationDashboardPaletteId`, or `StaffDashboardPaletteId`; nothing in the database records which, and nothing prevents a value matching no palette anywhere. The client must resolve it against the union of the three loaded lists. If the referenced palette is later soft-deleted, the selection row survives pointing at nothing.

---

## 7. Stored Procedures

**173 procedures total: 144 auto-generated CRUD + 29 hand-written.**

### 7.1 Auto-Generated CRUD (144 procedures)

> ⚠️ **The `_AutoGenerated` suffix was stripped from every procedure name on 2026-04-09** (RoundhousE script `069.XMSE-1048_Rename_AutoGenerated_Sprocs.sql`). The callable name is `{Table}_{Operation}` — e.g. `OrganisationDashboardPalette_AddEntity`. Calling the old `_AutoGenerated` name fails.
>
> **Trap:** the rename used `sp_rename`, which does not rewrite procedure bodies. `sys.sql_modules.definition` still contains the OLD name in its `CREATE PROCEDURE` header, so grepping definitions finds `_AutoGenerated` while the object no longer answers to it. **Trust `sys.procedures.name`, never the definition text.**

Each dbo table gets up to 7 procedures following the pattern `{Table}_{Operation}`:

| Suffix | Operation | Notes |
|---|---|---|
| `_AddEntity` | INSERT + return new ID via `OUTPUT` | ⚠️ `DashboardGroup_AddEntity` **always fails** — see below |
| `_DeleteEntity` | ⚠️ **HARD `DELETE`** — not a soft delete | See below |
| `_GetEntity_ByIdentifier` | SELECT by PK | |
| `_GetList_Default` | SELECT all, ordered by TransactionId + PK | |
| `_GetPage_Default` | Paginated SELECT (@PageSize 1–1000, @PageNumber) | |
| `_TotalPages` | Page count for pagination | |
| `_UpdateEntity` | UPDATE by PK | Requires `@DateCreated` and overwrites it — round-trip the existing value |

**Count breakdown:** 18 tables × 7 = 126, plus 3 `*GroupMapping` × 6 (no `_AddEntity`) = 144. **Four tables have no CRUD set at all** — `DomainEventLog` and the three palette-selection tables (§6.3), which expose only `_Create` or `_Load`/`_Upsert`.

> ⚠️ **`_DeleteEntity` is a hard `DELETE`, not a soft delete.** Earlier revisions of this document said otherwise; that was wrong and it is the most dangerous error the 2026-07-29 audit found. Verified body:
> ```sql
> CREATE PROCEDURE [dbo].[OrganisationDashboardPalette_DeleteEntity_AutoGenerated]
> @OrganisationDashboardPaletteId uniqueidentifier
> AS BEGIN
>     DELETE FROM [dbo].[OrganisationDashboardPalette]
>     WHERE [OrganisationDashboardPaletteId] = @OrganisationDashboardPaletteId;
>     SELECT @@ROWCOUNT;
> END
> ```
> Because the colour FKs are `ON DELETE NO_ACTION`, calling it on a palette that still has colour rows throws an FK violation; calling it on a child row destroys it outright, leaving only the `D` audit row as a record.
>
> **The soft-delete path is the separate `{Table}_Delete` family** (no `Entity`) — one word apart from the destructive one. It exists for only **10** tables: `BiConfig`, `DashboardConfig`, `DashboardGrid`, `DashboardGridFilter`, `DashboardGridItem`, `DashboardGroup`, `DashboardGroupMapping`, `DashboardPalette`, `DashboardPaletteColour`, `OrganisationDashboardConfig`. There is **no** `_Delete` for `OrganisationDashboardGroupMapping`, any `Staff*` table, `VisualisationConfig`, `VisualisationDataSetMap`, `VisualisationProcedure`, or any org/staff palette table — deletes there are unavoidably hard unless you write `UPDATE … SET IsDeleted = 1` by hand.

> ⚠️ **`DashboardGroup_AddEntity` can never succeed.** Its INSERT column list is `(ParentDashboardGroupId, Name, OrganisationId, StaffId)` — it omits `SortOrder`, which is `NOT NULL` with no default (§5.3). Every call fails with *"Cannot insert the value NULL into column 'SortOrder'"*. Use the hand-written `DashboardGroup_Create` instead, which supplies `@SortOrder` and hard-codes `IsDeleted = 0`.

### 7.2 Hand-Written Business Logic (29 procedures)

The nine below are the original set. **Twenty more have been added since the March audit** — see §7.2.1.

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

**Note on `OrganisationDashboardPalettes_Load` — a live data-correctness bug.** Its second result set reads:
```sql
WHERE [OrganisationDashboardPaletteColour].[IsDeleted] = 0
AND [OrganisationDashboardPaletteColour].[IsDeleted] = 0 AND [OrganisationId] = @OrganisationIdentifier;
```
The duplicated child predicate has **displaced the parent check** — `OrganisationDashboardPalette.IsDeleted = 0` is never tested. Colours belonging to a soft-deleted org palette are therefore returned in result set 2 while the palette itself is correctly filtered out of result set 1, sending orphan colours to the client. `StaffDashboardPalettes_Load` checks both sides correctly, confirming this is a copy-paste defect rather than intent. Latent on UAT today (all 3 org palettes are live), but it will bite the first time an org palette is soft-deleted. **Mitigation until fixed: soft-delete the colour rows whenever you soft-delete an org palette.**

#### 7.2.1 Added since the March audit

| Procedure | Added | Deployed by | Purpose |
|---|---|---|---|
| `BiConfig_Get_ForOrganisationId` | 2026-05-21 | RoundhousE `070` | `TOP 1` live `BiConfig` row — lightweight alternative to the 4-result-set `BiConfig_GetEntities_ByOrganisationIdentifier`. ⚠️ Its parameter is `@OrganisationId`, breaking the `@OrganisationIdentifier` convention every other hand-written SP follows. |
| `DomainEventLog_Create` | 2026-06-23 | RoundhousE `073` | Idempotent event inbox — returns `(Id, IsNew)`. See §3.6. |
| `StaffDefaultPalette_Load` / `_Upsert` | 2026-04-09 | RoundhousE `060`–`062` | Palette selection, account granularity (§6.3) |
| `StaffDashboardDefaultPalette_Load` / `_Upsert` | 2026-04-09 | RoundhousE `063`–`065` | Palette selection, per-dashboard |
| `StaffDashboardItemDefaultPalette_Load` / `_Upsert` | 2026-04-29 | RoundhousE `066`–`068` | Palette selection, per-card |
| `DashboardGroup_Create` | 2026-07-06 | ⚠️ **by hand** | The correct group-creation path (`DashboardGroup_AddEntity` is broken) |
| `DashboardGroupMapping_Create` | 2026-07-06 | ⚠️ **by hand** | True upsert — un-deletes on composite-key hit |
| 10 × `{Table}_Delete` | 2026-07-06 | ⚠️ **by hand** | The soft-delete family (§7.1). Verified `UPDATE … SET IsDeleted = 1 WHERE …Id = @… AND IsDeleted = 0`. **None cascade** — soft-deleting a grid leaves its items and filters live; soft-deleting a group leaves its mappings. |

> ⚠️ **RELEASE-PROCESS GAP: the twelve 2026-07-06 procedures were deployed outside RoundhousE and will NOT reach Prod via migration.**
> All twelve have `create_date` = `modify_date` = 2026-07-06 13:24–15:00 UTC, but `RoundhousE.ScriptsRun` jumps straight from id 95 (2026-06-23) to id 96 (2026-07-10), and neither of the two later "everytime" runs (07-10, 07-15) touched their `modify_date` — so they are absent from the migration set entirely, not merely out of sequence.
> **Consequence:** on any environment built from RoundhousE, the entire soft-delete `_Delete` family and both `_Create` upserts **do not exist** — leaving `_DeleteEntity` (a hard delete) as the only available path. These must be committed as numbered migration scripts before Prod dashboard configuration begins.
> Detect with: `SELECT name, create_date FROM sys.procedures WHERE CAST(create_date AS DATE) = '2026-07-06'`.

### 7.3 Triggers (48 total)

Two triggers per audited table:

| Pattern | Event | Action |
|---|---|---|
| `{Table}_Updated` | AFTER UPDATE | Sets `DateUpdated = SYSUTCDATETIME()` |
| `{Table}_Audit` | AFTER INSERT, UPDATE, DELETE | Writes to `Audit.{Table}` with action code (`I`/`U`/`D`) |

`AppVersion` and `DomainEventLog` have only `_Updated` (no audit trigger — both are excluded from the audit schema). 23 audited tables × 2 = 46, plus those 2 = 48.

> ⚠️ **Two `_Audit` triggers are broken and block their tables entirely** — `DashboardConfig_Audit` and `StaffDashboardConfig_Audit`. See the warning in §5; this is why the platform-default and staff tiers are empty.

---

## 8. Audit System

### 8.1 Design

Every audited `dbo` table has a mirror in the `Audit` schema with three extra columns prepended. **Two dbo tables are unaudited and have no mirror: `AppVersion` and `DomainEventLog`** (25 dbo − 2 = 23 Audit tables).

| Column | Type | Purpose |
|---|---|---|
| `AuditId` | `bigint` (PK, IDENTITY) | Surrogate audit key |
| `AuditAction` | `char(1)` | `I` = Insert, `U` = Update, `D` = Delete |
| `AuditDate` | `datetime2` (DEFAULT `SYSUTCDATETIME()`) | When the change occurred |

**Limitations:**
- **No user identity** is captured — only what changed and when, not who. (`DomainEventLog.LastUpdatedByUserId`, added 2026-06-23, is the first user-identity column in the database, but it sits outside the audit system.)
- **No before/after diff** — for updates, only the post-change state (from `inserted`) is recorded; reconstructing previous state requires comparing consecutive `U` rows by `AuditId`
- **The mirror must be kept in step with its source table by hand.** When columns are added to a dbo table, the `Audit` mirror gains them as `NOT NULL` with no default, and the `_Audit` trigger must be updated to populate them or **every write to the source table fails**. This has already happened twice and is still unfixed — see §5 and §12.

### 8.2 Audit Row Counts

The difference between audit rows and live rows reveals edit history:

Measured 2026-07-29 (live = `IsDeleted = 0`; total = all rows in dbo):

| Table | Live | Total (dbo) | Audit Rows |
|---|---|---|---|
| DashboardGridItem | 490 | 551 | 1151 |
| VisualisationDataSetMap | 742 | 761 | 938 |
| VisualisationConfig | 187 | 190 | 242 |
| DashboardGridFilter | 109 | 145 | 217 |
| OrganisationDashboardConfig | 86 | 86 | 96 |
| OrganisationDashboardGroupMapping | 86 | 86 | 87 |
| DashboardGrid | 75 | 75 | 75 |
| DashboardGroup | 19 | 19 | 19 |
| BiConfig | 18 | 18 | 34 |
| VisualisationProcedure | 16 | 16 | 26 |
| AppVersion, DomainEventLog | — | 17 / 0 | *no mirror* |

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
| 2026-02-20 | 1.0.65162 | — | SP updates |
| 2026-04-09 | 1.0.18 | 16 | **Largest release to date.** Scripts `014`–`019` rebuilt `DashboardConfig` / `OrganisationDashboardConfig` / `StaffDashboardConfig` **and their audit tables** — this is when `IconName` + `SortOrder` were appended (and when the two audit triggers were left behind, §5). `020`/`021` created `OrganisationDashboardConfig_Load` + `StaffDashboardConfig_Load`. `060`–`065` added the first two palette-selection tables (§6.3). **`069.XMSE-1048_Rename_AutoGenerated_Sprocs.sql` — the global CRUD rename** (§7.1). |
| 2026-04-29 | 1.0.30 | 4 | `066`–`068`: `StaffDashboardItemDefaultPalette` + audit + `_Load`/`_Upsert` |
| 2026-05-15 | 1.0.34 | 1 | "Everytime" GUID script only — SP redeploy, no schema change |
| 2026-05-21 | 1.0.38 | 2 | `070`: `BiConfig_Get_ForOrganisationId` |
| 2026-06-05 | 1.0.45 | 1 | "Everytime" only |
| 2026-06-23 | 1.0.51 | 4 | `071`–`073`: **XMSE-1323 — `DomainEventLog`** table + class + `_Create` (§3.6) |
| **2026-07-06** | *(none)* | **0** | ⚠️ **OUT-OF-BAND — 12 procedures deployed by hand, no `ScriptsRun` or `Version` row.** The `_Delete` soft-delete family + 2 `_Create` upserts. See the warning in §7.2.1. |
| 2026-07-10 | 1.0.54 | 1 | "Everytime" only |
| 2026-07-15 | 1.0.59 | 1 | "Everytime" only — **most recent RoundhousE run** |

**`ScriptsRunErrors` is empty — no migration has ever failed.** 15 `Version` rows record zero scripts; those are blue-green partner runs (§9.2).

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
| `XMSE-1048` | Rename of all auto-generated CRUD SPs — dropped the `_AutoGenerated` suffix (§7.1) |
| `XMSE-1323` | `DomainEventLog` domain-event inbox (§3.6) |

**Note:** script `047` is named *"XMSE-420 Palette Classification.sql"*, so the palette column classification belongs to XMSE-420, not XMSE-642 as previously recorded here.

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

DomainEventLog ◄──── DomainEventLog.ParentDomainEventLogId (self-ref, FK_DomainEventLog_DomainEventLog)

BiConfig (standalone — OrganisationId is not FK-constrained)
AppVersion (standalone — no relationships)
```

**15 foreign keys in total**, all `ON DELETE NO_ACTION` — nothing cascades anywhere in this database, so children must always be cleaned up explicitly.

**FK naming is unreliable — do not infer the referenced column from the constraint name.** `FK_OrganisationDashboardPaletteColour_DashboardPaletteId` and `FK_StaffDashboardPaletteColour_DashboardPaletteId` both reference their *own* tier's key (`OrganisationDashboardPaletteId` / `StaffDashboardPaletteId`), not `DashboardPaletteId`.

**Notable FK gaps (no declared constraint):**
- `StaffDefaultPalette.PaletteId`, `StaffDashboardDefaultPalette.PaletteId`, `StaffDashboardItemDefaultPalette.PaletteId` → **no FK and no discriminator**; may reference any of the three palette tiers (§6.3)
- `StaffDashboardDefaultPalette.DashboardGridId`, `StaffDashboardItemDefaultPalette.DashboardGridId` / `.DashboardGridItemId` → `DashboardGrid` / `DashboardGridItem` (unconstrained)
- `OrganisationDashboardConfig.DashboardGridId` → `DashboardGrid` (enforced only at SP level)
- `StaffDashboardConfig.DashboardGridId` → `DashboardGrid` (enforced only at SP level)
- `DashboardGridItem.VisualisationId` → `VisualisationProcedure` (loose integer join)
- `VisualisationConfig.VisualisationId` → `VisualisationProcedure` (no FK)
- `BiConfig.OrganisationId`, `VisualisationConfig.OrganisationId`, `OrganisationDashboardConfig.OrganisationId` → `organisation` microservice DB (cross-database, cannot be FK-constrained)

---

## 11. Data Flow: How a Dashboard Renders

> **Update (2026-05-18):** Step 1 now goes through `DashboardGroup_Load`, not the flat `OrganisationDashboardConfig_Load`. The legacy SP still exists but the front end has switched to the group-driven navigation. Dashboards must be reachable from a visible group to appear in the UI.

```
1. User opens dashboard
   │
   ├─► DashboardGroup_Load(@OrgId, @StaffId)
   │   Returns 4 result sets:
   │     (a) Visible groups (platform-wide + org-wide + staff-personal that match the caller)
   │     (b) DashboardConfig rows joined via DashboardGroupMapping
   │     (c) OrganisationDashboardConfig rows joined via OrganisationDashboardGroupMapping
   │     (d) StaffDashboardConfig rows joined via StaffDashboardGroupMapping
   │   The UI builds the navigation tree from (a) and lists dashboards under each group from (b)/(c)/(d).
   │   Config rows NOT joined to a visible group are silently omitted.
   │
   ├─► DashboardPalettes_Load() + OrganisationDashboardPalettes_Load(@OrgId)
   │     [+ StaffDashboardPalettes_Load(@OrgId, @StaffId)]
   │   Returns: three INDEPENDENT palette lists — no server-side merge or precedence.
   │   Optionally also the selection tier (StaffDefaultPalette / *DashboardDefaultPalette /
   │   *DashboardItemDefaultPalette), which returns bare keys + an unconstrained PaletteId.
   │   The client resolves narrowest-wins and composes. See §6.3.
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

All entries re-verified 2026-07-29.

### Blocking defects

| Issue | Details |
|---|---|
| ⚠️ **12 procedures deployed outside RoundhousE (2026-07-06)** | The whole soft-delete `_Delete` family plus `DashboardGroup_Create` / `DashboardGroupMapping_Create` exist on UAT by hand only, with no migration script. **They will not reach Prod**, leaving hard-delete `_DeleteEntity` as the only path there. Must be committed as numbered scripts. Full detail in §7.2.1. |
| ⚠️ **`DashboardConfig_Audit` / `StaffDashboardConfig_Audit` broken** | Both omit `DashboardGridId`, `IconName`, `SortOrder`, which are `NOT NULL` in the audit mirror — so **any write to `dbo.DashboardConfig` or `dbo.StaffDashboardConfig` fails**. The platform-default and staff tiers cannot be populated until fixed. `OrganisationDashboardConfig_Audit` was fixed; these two were missed in the 2026-04-09 rebuild. See §5. |
| ⚠️ **`_DeleteEntity` is a hard `DELETE`** | Documented as a soft delete until this audit. Destroys rows on tables the design treats as never physically deleted; only the `D` audit row survives. The `{Table}_Delete` family is the soft path and covers just 10 of 25 tables. See §7.1. |
| ⚠️ **`DashboardGroup_AddEntity` always throws** | Omits `NOT NULL` `SortOrder`, which has no default. Use `DashboardGroup_Create`. See §7.1. |

### Correctness defects

| Issue | Details |
|---|---|
| **Soft-deleting a group mapping has no effect** | `DashboardGroup_Load` never filters the mapping tables' own `IsDeleted`, so the sanctioned "unpublish a dashboard" path leaves it fully visible. Most likely of these to bite next. §5.3 defect 1. |
| **Platform-wide groups leak cross-org** | The org-tier result set filters `IsDeleted` but not `OrganisationId`, so a group with `OrganisationId IS NULL` surfaces one org's dashboards in every org's nav. 0 rows today, nothing prevents it. §5.3 defect 2. |
| **Orphan colours from `OrganisationDashboardPalettes_Load`** | A duplicated child `IsDeleted` predicate displaced the parent check, so colours of a soft-deleted org palette still reach the client. Previously logged here as merely "redundant"; it is a data-correctness bug. §7.2. |
| **`_UpdateEntity` overwrites `DateCreated`** | Required parameter on a plain UPDATE — round-trip the existing value or lose provenance. |
| **Group names ≥256 chars break all navigation** | `DashboardGroup.Name` is `nvarchar(256)` but `#VisibleGroups.Name` inside `DashboardGroup_Load` is `NVARCHAR(255)`, so one long name throws a truncation error and kills nav for that caller. Longest current name: 14 chars. |

### Design traps (working as built, easy to get wrong)

| Issue | Details |
|---|---|
| **Dashboards invisible without a group** | Still true as a mechanism, but **UAT data is now clean**: all 86 live `OrganisationDashboardConfig` rows have exactly one live mapping, and 0 configs are ungrouped. Keep the warning for provisioning and environment promotion; it is no longer an outstanding data problem. *(This is what ledger item O13 mistook for a fault — it audited the unused platform-tier `DashboardGroupMapping` instead of `OrganisationDashboardGroupMapping`.)* |
| **No org-level palette selection** | An `OrganisationDashboardPalette` row only offers a bespoke palette; all three selection tables require `StaffId`. Brand colours cannot be applied org-wide. §6.3. |
| **`PaletteId` is an untyped cross-table pointer** | No FK, no discriminator, three possible parents. §6.3. |
| **`SortOrder` collisions are silent** | No unique constraints and no `ORDER BY` in `DashboardGroup_Load`. Already real: 4 groups have tied dashboard positions, 9 grids have tied item positions, and 4 system palettes share `SortOrder` 70. |
| **Grids are shared across organisations** | Editing one grid changes every dashboard pointing at it; `050FCDB8-…` serves 6 orgs. §4.1. |
| **Empty groups still render** | `Development` (Dirty Sixth) has 0 mapped dashboards and appears as an empty nav node. Nothing filters childless groups. |
| **Group nesting is untested** | `ParentDashboardGroupId` works and is returned, but has 0 non-NULL rows and no cycle detection. |
| **`AppVersion.Number` is non-monotonic** | Counter reset in April 2026 — do not use it for ordering or freshness. §3.5. |

### Cosmetic / data-entry

| Issue | Details |
|---|---|
| `VisualisationId` 14 gap | `FilterList` intentionally excluded from `VisualisationProcedure` (handled separately by the microservice) — **by design, not a defect** |
| Misspelled dataset `InvUseAnalisys` | Still live in both `DashboardGridItem.DataSet` and `VisualisationDataSetMap.DataSet`; sibling `InvWasteAnalysis` is spelled correctly. Must match MI exactly |
| Yellow palette duplicate | Positions 60 and 70 both `#AB6208` — 8 colours, 7 distinct |
| Malformed constraint names | **14, not 3** — stray `[` on both `PK_[` and `CX_[` for seven tables: `DashboardConfig`, `DashboardGrid`, `DashboardGridFilter`, `DashboardGridItem`, `OrganisationDashboardConfig`, `StaffDashboardConfig`, `VisualisationConfig`. The newer group tables are clean |
| FK naming inconsistency | **Two, not one** — both `FK_OrganisationDashboardPaletteColour_DashboardPaletteId` and `FK_StaffDashboardPaletteColour_DashboardPaletteId` are misnamed. See §10 |
| FK typo | `FK_DashboardConfigm_DashboardGridId` — extra `m` |

### Resolved since the March audit

| Issue | Resolution |
|---|---|
| ~~Missing BiConfig for SurveyHero org~~ | **Fixed.** `3EBF26FE-…` now has `BiConfig` (`DbPrefix` `20251202`) and is UAT's most-provisioned org (17 card types). Zero orgs now lack a `BiConfig` row |
| ~~`core.StaticBoxCard` not in MI release scripts~~ | **Fixed.** Present in `releases/v1.0-baseline/8_Deployment_Objects_Records.sql` and `8_VisualisationQueries.sql` |
| ~~Survey coverage minimal (2 of 37 wired)~~ | **Was wrong by an order of magnitude.** 115 distinct live survey datasets are wired — more than the 37 in the MI release scripts. §3.4 |
| ~~`RedLionNetsSalesLW` typo~~ | Correctly soft-deleted and replaced by `RedLionNetSalesLW` |
