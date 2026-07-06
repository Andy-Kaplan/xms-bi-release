# Bizon001 Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the Bizon POS integration (`int_bizon001`) — 5 SQL scripts delivering 26 DL tables, 36 staging steps, 40 entity mappings, and 2 new Data Vault entities (BOOKING v2, BOOKING_CUSTORDER).

**Architecture:** Single integration schema `int_bizon001` with IntegrationType `POS`. Follows the standard 5-file pattern (INIT → DDL → Staging → Mapping → Final). All scripts use upsert patterns for idempotent re-runs. A prerequisite Task 0 adds the two new DV entity records to the core platform file. Scripts authored in `ClaudeDevelopment/integrations/Bizon/`, promoted to `Bizon/` at release time.

**Tech Stack:** SQL Server (Managed Instance), T-SQL, upsert patterns (IF EXISTS UPDATE ELSE INSERT for GlobalParameters/StagingControl, IF EXISTS UPDATE ELSE INSERT for EntityMappings).

**Design Spec:** `ClaudeDevelopment/integrations/Bizon/2026-04-09-bizon-integration-design.md`

---

## File Structure

| File | Purpose | Estimated Lines |
|---|---|---|
| `ClaudeDevelopment/integrations/Bizon/00_Bizon_DataVaultEntities.sql` | 2 new DV entity records (BOOKING v2 Live, BOOKING_CUSTORDER Live) | ~80 |
| `ClaudeDevelopment/integrations/Bizon/01_Bizon001_INIT.sql` | Register integration + APIEndpointDetail JSON skeleton | ~80 |
| `ClaudeDevelopment/integrations/Bizon/02_Bizon001_DDL.sql` | 26 DL table DDLs as STAGE_DDL GlobalParameters | ~700 |
| `ClaudeDevelopment/integrations/Bizon/03_Bizon001_Staging.sql` | 36 StagingControl upserts (Tiers 1-3) | ~2,500 |
| `ClaudeDevelopment/integrations/Bizon/04_Bizon001_Mapping.sql` | 40 EntityMappings upserts (25 hub + 15 link) | ~1,200 |
| `ClaudeDevelopment/integrations/Bizon/05_Bizon001_Final.sql` | EXEC UploadEntityMappings | ~15 |

**Prerequisite:** Before deploying scripts 02-05 to any environment, `sp_CreateIntegrationTables` must have been run to create the `int_bizon001` schema with its StagingControl, EntityMappings, and GlobalParameters tables. This is called manually between scripts 01 and 02.

**Fetcher prerequisite:** The Mews POS API uses JSON:API format (`application/vnd.api+json`) with `data`/`included` sideloading, `relationships` references, and `attributes` wrappers. This is structurally different from the plain REST JSON used by NCRAloha and Square. **The fetcher team will need to build a new JSON:API unravel method** into the fetcher process before data can land in DL tables. The INIT script provides an `APIEndpointDetail` skeleton, but the fetcher team must implement the JSON:API parsing capability.

**Key conventions:**
- Mews amounts are string decimals ("10.50") — staging uses `CAST(field AS DECIMAL(18,2))` with **no division by 100**
- Invoice is the CUSTORDER source (not Order) — avoids double-counting with split bills
- Split-bill invoices carry full `covers` from parent Order — no division
- Staging filter: `WHERE inv.cancelled != 'true' OR inv.cancelled IS NULL` — start with `status = 'paid'` only; `closed` status meaning unconfirmed (revisit with sample data)
- Revenue Centers → REVCENTER hub (not OCCASION — no occasion data in Mews API)
- Areas → CHANNEL hub
- No workforce (EMPLOYEE/JOB/TIMECARD) — Mews POS API has no shift endpoint
- BOOKING is a new Live DV entity (v2) — first integration to populate it

---

## Task 0: New Data Vault Entity Definitions

**Files:**
- Create: `ClaudeDevelopment/integrations/Bizon/00_Bizon_DataVaultEntities.sql`

Two new entity records are needed in the core platform. The existing Build-state `BOOKING` (v1) and `ASSET_BOOKING_CUSTORDER` (v1) are left unchanged.

- [ ] **Step 1: Write the DataVaultEntities script**

This script adds BOOKING v2 (Live hub) and BOOKING_CUSTORDER v1 (Live link). Both use MERGE to be idempotent. The BOOKING v2 record has 10 satellite attributes for table reservation data. The BOOKING_CUSTORDER link is a binary link with no SAT_LNK attributes.

```sql
-- Bizon Integration: New Data Vault Entities
-- BOOKING v2 (Live Hub) + BOOKING_CUSTORDER v1 (Live Binary Link)
-- Prerequisite: Run against core database before integration deployment

-- ============================================
-- Entity: BOOKING (Version 2 - Live)
-- ============================================
-- Note: Version 1 (Build) remains unchanged
MERGE INTO [core].[core].[DataVaultEntities] AS tgt
USING (VALUES (
    N'BOOKING',
    2,
    N'Live',
    N'1',
    N'PoS',
    1,
    N'BOOKING_DATE',
    N'Table/space reservations from POS systems (Mews bookings)',
    N'["BOOKING_STATUS", "PARTY_SIZE", "BOOKING_DATETIME", "BOOKING_DATE", "DURATION_MINS", "IS_WALKIN", "DEPOSIT_AMOUNT", "BOOKING_REFERENCE", "ROOM_NUMBER", "NOTES"]',
    N'[{"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": "Booking status: confirmed/seated/completed/cancelled/no_show"}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": "Number of guests in reservation"}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": false, "description": "Scheduled reservation date/time"}, {"data_type": "DATETIME2(7)", "nullable": true, "business_key": false, "time_series": true, "description": "Business date for time series"}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": "Duration in minutes"}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": "Walk-in flag true/false"}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "time_series": false, "description": "Deposit amount"}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": "External booking reference"}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "time_series": false, "description": "Hotel room number"}, {"data_type": "NVARCHAR(MAX)", "nullable": true, "business_key": false, "time_series": false, "description": "Free-text notes"}]'
)) AS src (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE, TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES)
ON tgt.ENTITY_NAME = src.ENTITY_NAME AND tgt.VERSION = src.VERSION
WHEN MATCHED THEN
    UPDATE SET
        RELEASE_STATE = src.RELEASE_STATE,
        SPLIT_MAP = src.SPLIT_MAP,
        PRIMARY_SOURCE_TYPE = src.PRIMARY_SOURCE_TYPE,
        TIME_SERIES = src.TIME_SERIES,
        TIME_SERIES_COLUMN = src.TIME_SERIES_COLUMN,
        DESCRIPTION = src.DESCRIPTION,
        ATTRIBUTE_NAMES = src.ATTRIBUTE_NAMES,
        ATTRIBUTE_TYPES = src.ATTRIBUTE_TYPES,
        UPDATED_AT = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
            TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
            CREATED_AT, UPDATED_AT)
    VALUES (src.ENTITY_NAME, src.VERSION, src.RELEASE_STATE, src.SPLIT_MAP, src.PRIMARY_SOURCE_TYPE,
            src.TIME_SERIES, src.TIME_SERIES_COLUMN, src.DESCRIPTION, src.ATTRIBUTE_NAMES, src.ATTRIBUTE_TYPES,
            GETDATE(), GETDATE());
GO

-- ============================================
-- Entity: BOOKING_CUSTORDER (Version 1 - Live)
-- ============================================
MERGE INTO [core].[core].[DataVaultEntities] AS tgt
USING (VALUES (
    N'BOOKING_CUSTORDER',
    1,
    N'Live',
    N'1_1',
    NULL,
    0,
    NULL,
    N'Link connecting BOOKING to CUSTORDER (reservation to invoice)',
    N'[]',
    N'[]'
)) AS src (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE, TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES)
ON tgt.ENTITY_NAME = src.ENTITY_NAME AND tgt.VERSION = src.VERSION
WHEN MATCHED THEN
    UPDATE SET
        RELEASE_STATE = src.RELEASE_STATE,
        SPLIT_MAP = src.SPLIT_MAP,
        PRIMARY_SOURCE_TYPE = src.PRIMARY_SOURCE_TYPE,
        TIME_SERIES = src.TIME_SERIES,
        TIME_SERIES_COLUMN = src.TIME_SERIES_COLUMN,
        DESCRIPTION = src.DESCRIPTION,
        ATTRIBUTE_NAMES = src.ATTRIBUTE_NAMES,
        ATTRIBUTE_TYPES = src.ATTRIBUTE_TYPES,
        UPDATED_AT = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (ENTITY_NAME, VERSION, RELEASE_STATE, SPLIT_MAP, PRIMARY_SOURCE_TYPE,
            TIME_SERIES, TIME_SERIES_COLUMN, DESCRIPTION, ATTRIBUTE_NAMES, ATTRIBUTE_TYPES,
            CREATED_AT, UPDATED_AT)
    VALUES (src.ENTITY_NAME, src.VERSION, src.RELEASE_STATE, src.SPLIT_MAP, src.PRIMARY_SOURCE_TYPE,
            src.TIME_SERIES, src.TIME_SERIES_COLUMN, src.DESCRIPTION, src.ATTRIBUTE_NAMES, src.ATTRIBUTE_TYPES,
            GETDATE(), GETDATE());
GO
```

- [ ] **Step 2: Commit**

```bash
git add ClaudeDevelopment/integrations/Bizon/00_Bizon_DataVaultEntities.sql
git commit -m "feat(bizon): add BOOKING v2 Live hub + BOOKING_CUSTORDER Live link entities"
```

---

## Task 1: INIT Script

**Files:**
- Create: `ClaudeDevelopment/integrations/Bizon/01_Bizon001_INIT.sql`

- [ ] **Step 1: Write the INIT script**

The INIT registers the integration, sets `IntegrationType = 'POS'`, and stores a JSON:API-specific `APIEndpointDetail` skeleton. The `APIEndpointDetail` JSON documents all Mews POS API endpoints with their paths, HTTP methods, and the JSON:API-specific `include` parameters needed for relationship sideloading.

```sql
USE [core]
GO

DECLARE @return_value int

EXEC @return_value = [core].[AddIntegration]
        @IntegrationName = N'Bizon001',
        @IntegrationDisplayName = N'Bizon POS (Mews) Version 1'

SELECT 'Return Value' = @return_value

GO


UPDATE [core].[Integrations] SET
[APIEndpointDetail] = '{
    "api_info": {
        "source": "mews",
        "version": "v1",
        "base_url": "https://api.mews.com/pos/v1",
        "format": "jsonapi",
        "auth_type": "bearer_token",
        "content_type": "application/vnd.api+json"
    },
    "endpoints": {
        "outlets": {
            "description": "Physical locations/stores",
            "endpoint": "outlets",
            "unique_identifier": "id",
            "request_method": "GET",
            "jsonapi_include": []
        },
        "areas": {
            "description": "Dining areas within outlets",
            "endpoint": "areas",
            "unique_identifier": "id",
            "request_method": "GET",
            "jsonapi_include": ["tables"]
        },
        "tables": {
            "description": "Restaurant tables",
            "endpoint": "tables",
            "unique_identifier": "id",
            "request_method": "GET",
            "jsonapi_include": ["area"]
        },
        "registers": {
            "description": "POS terminal devices",
            "endpoint": "registers",
            "unique_identifier": "id",
            "request_method": "GET",
            "jsonapi_include": ["outlet"]
        },
        "products": {
            "description": "Menu items with types, variants, modifiers",
            "endpoint": "products",
            "unique_identifier": "id",
            "request_method": "GET",
            "jsonapi_include": ["productType", "modifierSets", "productVariants", "modifiers", "taxes"],
            "delta_column": "updatedAt",
            "delta_filter": "filter[updatedAtGt]"
        },
        "modifier_sets": {
            "description": "Modifier group containers",
            "endpoint": "modifier-sets",
            "unique_identifier": "id",
            "request_method": "GET",
            "jsonapi_include": ["modifiers"]
        },
        "orders": {
            "description": "Customer orders with items, bundles, payments",
            "endpoint": "orders",
            "unique_identifier": "id",
            "request_method": "GET",
            "jsonapi_include": ["invoice", "customer", "booking", "tables", "promoCode", "outlet", "revenueCenter", "taxes", "orderItems"],
            "delta_column": "updatedAt",
            "delta_filter": "filter[updatedAtGt]"
        },
        "invoices": {
            "description": "Finalized bills (primary financial record)",
            "endpoint": "invoices",
            "unique_identifier": "id",
            "request_method": "GET",
            "jsonapi_include": ["user", "register", "invoiceItems", "order", "promoCode", "revenueCenter"],
            "delta_column": "createdAt",
            "delta_filter": "filter[createdAtGt]"
        },
        "customers": {
            "description": "Guest profiles",
            "endpoint": "customers",
            "unique_identifier": "id",
            "request_method": "GET",
            "jsonapi_include": []
        },
        "bookings": {
            "description": "Table reservations",
            "endpoint": "bookings",
            "unique_identifier": "id",
            "request_method": "GET",
            "jsonapi_include": ["customer", "orders", "tables"],
            "delta_column": "updatedAt",
            "delta_filter": "filter[updatedAtGt]"
        },
        "revenue_centers": {
            "description": "Revenue segmentation (bar, restaurant, etc.)",
            "endpoint": "revenue-centers",
            "unique_identifier": "id",
            "request_method": "GET",
            "jsonapi_include": []
        },
        "promo_codes": {
            "description": "Discount/promotional codes",
            "endpoint": "promo-codes",
            "unique_identifier": "id",
            "request_method": "GET",
            "jsonapi_include": []
        },
        "menus": {
            "description": "Menu configurations (reference only)",
            "endpoint": "menus",
            "unique_identifier": "id",
            "request_method": "GET",
            "jsonapi_include": ["menuSections", "outlets"]
        }
    },
    "pagination": {
        "type": "cursor",
        "page_size_param": "page[size]",
        "cursor_param": "page[after]",
        "max_page_size": 1000
    },
    "rate_limiting": {
        "header_limit": "X-Rate-Limit-Limit",
        "header_remaining": "X-Rate-Limit-Remaining",
        "header_reset": "X-Rate-Limit-Reset",
        "retry_after_header": "Retry-After"
    },
    "notes": {
        "format": "JSON:API - fetcher must resolve data/included/relationships structure",
        "amounts": "String decimals (e.g. 10.50) - no integer division needed",
        "invoice_filter": "Start with status=paid only; closed status semantics unconfirmed"
    }
}',
[IntegrationType] = 'POS'

WHERE [IntegrationName] = 'Bizon001'
```

**Note:** The `APIEndpointDetail` JSON includes JSON:API-specific fields (`jsonapi_include`, `format: "jsonapi"`) that the fetcher team will use when building the new JSON:API unravel capability. The `delta_filter` fields specify the Mews filter parameter names for incremental extraction.

- [ ] **Step 2: Commit**

```bash
git add ClaudeDevelopment/integrations/Bizon/01_Bizon001_INIT.sql
git commit -m "feat(bizon): add INIT script — register Bizon001 integration with Mews API config"
```

---

## Task 2: DDL Script (26 DL Tables)

**Files:**
- Create: `ClaudeDevelopment/integrations/Bizon/02_Bizon001_DDL.sql`

Every DL table follows the same pattern — all data columns `[nvarchar](max) NULL`, plus `LOADTS_UTC` and `INT_FETCH_DATE` system columns. The upsert pattern checks `GlobalParameters` for existing `STAGE_DDL` records.

- [ ] **Step 1: Write the DDL script with all 26 DL tables**

The DDL script uses the IF EXISTS UPDATE / ELSE INSERT upsert pattern against `core.[int_bizon001].[GlobalParameters]` with `Category = 'STAGE_DDL'`. Each table's CREATE TABLE statement is stored as a string in `ParameterValue`.

Write all 26 tables in this order, following the column definitions from the design spec §2:

1. `DL_ORDERS` — 20 columns (§2.1)
2. `DL_ORDER_ITEMS` — 17 columns (§2.1)
3. `DL_ORDER_ITEM_MODIFIERS` — 6 columns (§2.1)
4. `DL_ORDER_BUNDLES` — 7 columns (§2.1)
5. `DL_ORDER_PAYMENTS` — 8 columns (§2.1)
6. `DL_INVOICES` — 19 columns (§2.2)
7. `DL_INVOICE_ITEMS` — 21 columns (§2.2)
8. `DL_INVOICE_ITEM_MODIFIERS` — 5 columns (§2.2)
9. `DL_PRODUCT_TYPES` — 4 columns (§2.3)
10. `DL_PRODUCTS` — 13 columns (§2.3)
11. `DL_PRODUCT_VARIANTS` — 9 columns (§2.3)
12. `DL_MODIFIER_SETS` — 7 columns (§2.3)
13. `DL_MODIFIERS` — 6 columns (§2.3)
14. `DL_PRODUCT_BUNDLES` — 7 columns (§2.3)
15. `DL_OUTLETS` — 10 columns (§2.4)
16. `DL_AREAS` — 5 columns (§2.4)
17. `DL_TABLES` — 6 columns (§2.4)
18. `DL_REGISTERS` — 8 columns (§2.4)
19. `DL_CUSTOMERS` — 18 columns (§2.5)
20. `DL_BOOKINGS` — 14 columns (§2.6)
21. `DL_REVENUE_CENTERS` — 5 columns (§2.7)
22. `DL_PAYMENT_METHODS` — 7 columns (§2.7)
23. `DL_PROMO_CODES` — 12 columns (§2.7)
24. `DL_TAXES` — 9 columns (§2.7)
25. `DL_MENUS` — 10 columns (§2.8)
26. `DL_PAYMENTS` — 10 columns (§2.9 #26)

**Pattern for each table** (showing DL_OUTLETS as example):

```sql
-- Table: DL_OUTLETS
IF EXISTS (SELECT 1 FROM core.[int_bizon001].[GlobalParameters] WHERE ParameterKey = N'DL_OUTLETS' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_bizon001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_bizon001].[DL_OUTLETS](
	[id] [nvarchar](max) NULL,
	[name] [nvarchar](max) NULL,
	[address1] [nvarchar](max) NULL,
	[address2] [nvarchar](max) NULL,
	[city] [nvarchar](max) NULL,
	[state] [nvarchar](max) NULL,
	[postalCode] [nvarchar](max) NULL,
	[index] [nvarchar](max) NULL,
	[createdAt] [nvarchar](max) NULL,
	[updatedAt] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]',
        Description = N'DL_OUTLETS',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_OUTLETS' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_bizon001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_OUTLETS', N'CREATE TABLE [int_bizon001].[DL_OUTLETS](
	[id] [nvarchar](max) NULL,
	[name] [nvarchar](max) NULL,
	[address1] [nvarchar](max) NULL,
	[address2] [nvarchar](max) NULL,
	[city] [nvarchar](max) NULL,
	[state] [nvarchar](max) NULL,
	[postalCode] [nvarchar](max) NULL,
	[index] [nvarchar](max) NULL,
	[createdAt] [nvarchar](max) NULL,
	[updatedAt] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]',
    N'NVARCHAR', N'STAGE_DDL', N'DL_OUTLETS', 1, SYSTEM_USER, GETDATE(), N'1');
END
GO
```

Apply this pattern for all 26 tables. Column names must exactly match the design spec §2 column tables (camelCase from Mews API). Every table ends with `[LOADTS_UTC] [datetime2](7) NULL, [INT_FETCH_DATE] [datetime2](7) NULL`.

- [ ] **Step 2: Commit**

```bash
git add ClaudeDevelopment/integrations/Bizon/02_Bizon001_DDL.sql
git commit -m "feat(bizon): add DDL script — 26 DL table definitions"
```

---

## Task 3: Staging Script — Tier 1 Dimensions (Steps 1-9)

**Files:**
- Create: `ClaudeDevelopment/integrations/Bizon/03_Bizon001_Staging.sql`

All staging steps use the StagingControl upsert pattern (IF EXISTS UPDATE / ELSE INSERT). Each step's `query_sql` contains the idempotent `DROP TABLE IF EXISTS` + `SELECT INTO` staging pattern. Remember: strings inside `query_sql` must use doubled single quotes (`''`).

- [ ] **Step 1: Write the script header and all 9 dimension staging steps**

The 9 dimension staging steps are:

**Step 1 — Location** (`BIZ_LOCATION` from `DL_OUTLETS`)
- Tier 1, step_type = 'Staging'
- Dedup: `ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) = 1`
- Columns: ITEM_SRC_KEY=id, LOCATION_NAME=name, LOCATION_ID=id, LEVEL_NAME='BOTTOM', BOTTOM_LEVEL=1, PARENT_ID=NULL, MICROSERVICE_NAME=NULL, MICROSERVICE_ID=NULL

**Step 2 — Product Hierarchy** (`BIZ_PRODUCT` from `DL_PRODUCT_VARIANTS` + `DL_PRODUCTS` + `DL_PRODUCT_TYPES`)
- Tier 1, UNION ALL of 3 levels (BOTTOM/MIDDLE_1/TOP)
- Filter: `WHERE status != ''inactive'' OR status IS NULL`
- Dedup each level: `ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) = 1`

**Step 3 — Modifier Hierarchy** (`BIZ_MODIFIER` from `DL_MODIFIERS` + `DL_MODIFIER_SETS`)
- Tier 1, UNION ALL of 2 levels (BOTTOM/TOP)

**Step 4 — Tax** (`BIZ_TAX` from `DL_TAXES`)
- Tier 1, `TAX_MULTIPLIER = CAST(ratePercent AS DECIMAL(18,6)) / 100.0`
- Filter: `WHERE isActive = ''true''`

**Step 5 — Tender** (`BIZ_TENDER` from `DL_PAYMENT_METHODS`)
- Tier 1, Filter: `WHERE isActive = ''true''`

**Step 6 — Discount** (`BIZ_DISCOUNT` from `DL_PROMO_CODES`)
- Tier 1, `VALUE_TYPE = discountType`, `VALUE = CAST(amount AS DECIMAL(18,2))`, `IS_WASTE = 0`

**Step 7 — Channel** (`BIZ_CHANNEL` from `DL_AREAS`)
- Tier 1, Filter: `WHERE isActive = ''true''`
- Synthetic fallback: `UNION ALL SELECT ''NO_AREA'', ''No Area'', ''NO_AREA'', ''BOTTOM'', 1, NULL`

**Step 8 — Service Charge** (`BIZ_SERVICECHARGE` from `DL_ORDERS` surcharge fields)
- Tier 1, `SELECT DISTINCT surchargeType`

**Step 9 — Revenue Center** (`BIZ_REVCENTER` from `DL_REVENUE_CENTERS`)
- Tier 1, Filter: `WHERE isActive = ''true''`

Each step follows this StagingControl upsert pattern:

```sql
-- Step: Location
IF EXISTS (SELECT 1 FROM [core].[int_bizon001].[StagingControl] WHERE [step_name] = N'Location')
BEGIN
    UPDATE [core].[int_bizon001].[StagingControl]
    SET [staging_table] = N'BIZ_LOCATION',
        [query_sql] = N'IF OBJECT_ID(''stage.BIZ_LOCATION'', ''U'') IS NOT NULL
    DROP TABLE [stage].[BIZ_LOCATION];

SELECT * INTO [stage].[BIZ_LOCATION]
FROM (
    SELECT
        id AS ITEM_SRC_KEY,
        name AS LOCATION_NAME,
        id AS LOCATION_ID,
        ''BOTTOM'' AS LEVEL_NAME,
        1 AS BOTTOM_LEVEL,
        NULL AS PARENT_ID,
        NULL AS MICROSERVICE_NAME,
        NULL AS MICROSERVICE_ID
    FROM (
        SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn
        FROM [int_bizon001].[DL_OUTLETS]
    ) dedup
    WHERE rn = 1
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = N'Outlets → LOCATION dimension',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["ITEM_SRC_KEY", "LOCATION_NAME", "LOCATION_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "PARENT_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Location';
END
ELSE
BEGIN
    INSERT INTO [core].[int_bizon001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Location', N'BIZ_LOCATION', N'IF OBJECT_ID(''stage.BIZ_LOCATION'', ''U'') IS NOT NULL
    DROP TABLE [stage].[BIZ_LOCATION];

SELECT * INTO [stage].[BIZ_LOCATION]
FROM (
    SELECT
        id AS ITEM_SRC_KEY,
        name AS LOCATION_NAME,
        id AS LOCATION_ID,
        ''BOTTOM'' AS LEVEL_NAME,
        1 AS BOTTOM_LEVEL,
        NULL AS PARENT_ID,
        NULL AS MICROSERVICE_NAME,
        NULL AS MICROSERVICE_ID
    FROM (
        SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn
        FROM [int_bizon001].[DL_OUTLETS]
    ) dedup
    WHERE rn = 1
) AS source_query;',
    1, N'Staging', 0, N'Outlets → LOCATION dimension', NULL, 3, 30,
    N'["ITEM_SRC_KEY", "LOCATION_NAME", "LOCATION_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "PARENT_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
    GETDATE(), GETDATE());
END
GO
```

Apply this pattern for all 9 dimension steps. The query_sql for each must match the staging logic defined in the design spec §3.1.

- [ ] **Step 2: Commit**

```bash
git add ClaudeDevelopment/integrations/Bizon/03_Bizon001_Staging.sql
git commit -m "feat(bizon): add staging steps 1-9 — dimension staging (Tier 1)"
```

---

## Task 4: Staging Script — Tier 1 Transactional (Steps 10-17)

**Files:**
- Modify: `ClaudeDevelopment/integrations/Bizon/03_Bizon001_Staging.sql` (append)

- [ ] **Step 1: Append all 8 transactional staging steps**

These are the core POS transactional steps. The most complex is BIZ_CUSTORDER (Step 10) which joins DL_INVOICES → DL_ORDERS → DL_REGISTERS to build the CUSTORDER record.

**Step 10 — Customer Order** (`BIZ_CUSTORDER`)
- `HEADER_ID = CONCAT_WS(''-'', reg.outletId, inv.id)`
- Financials from Invoice: `GRAND_TOTAL = CAST(inv.total AS DECIMAL(18,2))`, etc.
- Metadata from Order: `GUEST_COUNT = CAST(ord.covers AS INT)`, `ORDER_STATUS = ord.state`
- `TRADING_DATE = CAST(COALESCE(inv.createdAt, ord.createdAt) AS DATE)`
- Filter: `WHERE (inv.cancelled != ''true'' OR inv.cancelled IS NULL)`
- Join: `DL_INVOICES inv LEFT JOIN DL_ORDERS ord ON inv.orderId = ord.id LEFT JOIN DL_REGISTERS reg ON inv.registerId = reg.id`

**Step 11 — Line Item PROD** (`BIZ_LINEITEM`)
- `SRC_KEY = CONCAT_WS(''-'', reg.outletId, ii.invoiceId, ii.id, ''PROD'')`
- `GROSS_VALUE = CAST(ii.totalInclDiscount AS DECIMAL(18,2))`
- `VOID_FLAG = CASE WHEN ii.isVoid = ''true'' OR ii.isComp = ''true'' THEN 1 ELSE 0 END`
- `PRODUCT_SRC_KEY = COALESCE(ii.productVariantId, ii.productId)`

**Step 12 — Line Item MOD** (`BIZ_LINEITEM_MOD`)
- `SRC_KEY = CONCAT_WS(''-'', reg.outletId, iim.invoiceId, iim.invoiceItemId, iim.id, ''MOD'')`
- `PARENT_SRC_KEY` = corresponding PROD line item's SRC_KEY

**Step 13 — Line Item TAX** (`BIZ_LINEITEM_TAX`)
- One tax row per invoice item where `taxInclDiscount != 0`

**Step 14 — Line Item DISCOUNT** (`BIZ_LINEITEM_DISCOUNT`)
- `GROSS_VALUE = CAST(ii.discount AS DECIMAL(18,2)) * -1` (negative)
- Only where `discount IS NOT NULL AND != 0`

**Step 15 — Line Item TENDER** (`BIZ_LINEITEM_TENDER`)
- One tender row per order payment in `DL_ORDER_PAYMENTS`
- `TENDER_SRC_KEY = op.paymentMethodId`

**Step 16 — Line Item SVC** (`BIZ_LINEITEM_SVC`)
- From `DL_ORDERS` surcharge fields where `surcharge IS NOT NULL AND != 0`

**Step 17 — Register Lookup** (`BIZ_REGISTER_LOOKUP`)
- Pure reference: `REGISTER_ID = id, OUTLET_ID = outletId, REGISTER_NAME = name`
- No DV entity mapping — used as JOIN source in other steps

- [ ] **Step 2: Commit**

```bash
git add ClaudeDevelopment/integrations/Bizon/03_Bizon001_Staging.sql
git commit -m "feat(bizon): add staging steps 10-17 — transactional staging (Tier 1)"
```

---

## Task 5: Staging Script — Tier 1 CRM, Booking, Reference (Steps 18-21)

**Files:**
- Modify: `ClaudeDevelopment/integrations/Bizon/03_Bizon001_Staging.sql` (append)

- [ ] **Step 1: Append all 4 remaining Tier 1 steps**

**Step 18 — Customer** (`BIZ_CUSTOMER`)
- `ITEM_SRC_KEY = id`, `FIRST_NAME = fullName`, `SURNAME = NULL`
- Address, email, phone, DOB fields pass through
- Dedup by id

**Step 19 — Booking** (`BIZ_BOOKING`)
- `ITEM_SRC_KEY = id`, `CUSTOMER_SRC_KEY = customerId`
- `BOOKING_STATUS = status`, `PARTY_SIZE = CAST(partySize AS DECIMAL(38,10))`
- `BOOKING_DATETIME = CAST(bookingDatetime AS DATETIME2)`
- `BOOKING_DATE = CAST(bookingDatetime AS DATE)`
- Dedup by id

**Step 20 — Table Reference** (`BIZ_TABLE`)
- Pure lookup: TABLE_ID, TABLE_NAME, AREA_ID, AREA_NAME, NUMBER_OF_SEATS
- Join DL_TABLES → DL_AREAS on areaId

**Step 21 — Menu Reference** (`BIZ_MENU`)
- Reference only — no DV mapping
- All menu fields pass through

- [ ] **Step 2: Commit**

```bash
git add ClaudeDevelopment/integrations/Bizon/03_Bizon001_Staging.sql
git commit -m "feat(bizon): add staging steps 18-21 — CRM, booking, reference (Tier 1)"
```

---

## Task 6: Staging Script — Tier 2 Link Steps (15 Steps)

**Files:**
- Modify: `ClaudeDevelopment/integrations/Bizon/03_Bizon001_Staging.sql` (append)

- [ ] **Step 1: Append all 15 Tier 2 link staging steps**

All Tier 2 steps produce two-column (or three-column for ternary) junction tables from Tier 1 staging tables. They read from `stage.BIZ_*` tables created in Tier 1.

| # | Step Name | Table | Link Entity | Key Logic |
|---|---|---|---|---|
| T2-1 | CustOrder Location | `BIZ_CUSTORDER_LOCATION` | CUSTORDER_LOCATION | `SELECT DISTINCT HEADER_ID, LOCATION_SRC_KEY FROM BIZ_CUSTORDER` |
| T2-2 | Channel CustOrder | `BIZ_CHANNEL_CUSTORDER` | CHANNEL_CUSTORDER | Join BIZ_CUSTORDER → BIZ_TABLE for AREA_ID |
| T2-3 | CustOrder LineItem | `BIZ_CUSTORDER_LINEITEM` | CUSTORDER_LINEITEM | UNION ALL from all 6 LINEITEM staging tables |
| T2-4 | LineItem Product | `BIZ_LINEITEM_PRODUCT` | LINEITEM_PRODUCT | `COALESCE(PRODUCT_VARIANT_SRC_KEY, PRODUCT_SRC_KEY)` |
| T2-5 | LineItem Tax | `BIZ_LINEITEM_TAX_LNK` | LINEITEM_TAX | TAX_SRC_KEY from BIZ_LINEITEM_TAX |
| T2-6 | Discount LineItem | `BIZ_DISCOUNT_LINEITEM` | DISCOUNT_LINEITEM | INVOICE_DISCOUNT_SRC from BIZ_LINEITEM_DISCOUNT |
| T2-7 | LineItem Mod | `BIZ_LINEITEM_MOD_LNK` | LINEITEM_MOD | MOD_SRC_KEY from BIZ_LINEITEM_MOD |
| T2-8 | LineItem Tender | `BIZ_LINEITEM_TENDER_LNK` | LINEITEM_TENDER | TENDER_SRC_KEY from BIZ_LINEITEM_TENDER |
| T2-9 | LineItem SvcCharge | `BIZ_LINEITEM_SVC_LNK` | LINEITEM_SVCCHARGE | SVC_SRC_KEY from BIZ_LINEITEM_SVC |
| T2-10 | CustOrder RevCenter | `BIZ_CUSTORDER_REVCENTER` | CUSTORDER_REVCENTER | REVCENTER_SRC_KEY from BIZ_CUSTORDER |
| T2-11 | Address Individual | `BIZ_ADDRESS_INDIVIDUAL` | ADDRESS_INDIVIDUAL | `CONCAT_WS(''-'', ITEM_SRC_KEY, ''HOME'')` |
| T2-12 | Contact Individual | `BIZ_CONTACT_INDIVIDUAL` | CONTACT_INDIVIDUAL | EMAIL + PHONE rows via UNION ALL |
| T2-13 | Booking CustOrder | `BIZ_BOOKING_CUSTORDER` | BOOKING_CUSTORDER | Join BIZ_BOOKING → DL_ORDERS → BIZ_CUSTORDER via bookingId |
| T2-14 | CustOrder Individual | `BIZ_CUSTORDER_INDIVIDUAL` | (future) | Order → Customer FK from DL_ORDERS |
| T2-15 | CustOrder Refund | `BIZ_CUSTORDER_REFUND` | CUSTORDER_REFUND | (future refund staging) |

**Note:** Steps T2-14 and T2-15 produce staging tables but currently have no DV entity mapping. They are included for forward compatibility. Set `exclude = 1` on these two steps until the corresponding entity mappings are added.

- [ ] **Step 2: Commit**

```bash
git add ClaudeDevelopment/integrations/Bizon/03_Bizon001_Staging.sql
git commit -m "feat(bizon): add staging steps T2-1 to T2-15 — link staging (Tier 2)"
```

---

## Task 7: Staging Script — Tier 3 Self-Referencing Link (1 Step)

**Files:**
- Modify: `ClaudeDevelopment/integrations/Bizon/03_Bizon001_Staging.sql` (append)

- [ ] **Step 1: Append the LINEITEM_LINEITEM self-referencing step**

**T3-1 — Modifier to Parent Line Item** (`BIZ_LINEITEM_LINEITEM`)
- Links MOD-type line items back to their parent PROD-type line item via `PARENT_SRC_KEY`
- SAT_LNK attributes: `LABEL = MOD_NAME, VALUE = GROSS_VALUE, INFO = NULL`
- Source: `BIZ_LINEITEM_MOD` where `PARENT_SRC_KEY IS NOT NULL`
- Columns: `PARENT_SRC_KEY, CHILD_SRC_KEY, LABEL, VALUE, INFO`

```sql
-- T3-1: Modifier to Parent Line Item (LINEITEM_LINEITEM self-ref)
-- query_sql content:
IF OBJECT_ID(''stage.BIZ_LINEITEM_LINEITEM'', ''U'') IS NOT NULL
    DROP TABLE [stage].[BIZ_LINEITEM_LINEITEM];

SELECT * INTO [stage].[BIZ_LINEITEM_LINEITEM]
FROM (
    SELECT DISTINCT
        lm.PARENT_SRC_KEY,
        lm.SRC_KEY AS CHILD_SRC_KEY,
        lm.MOD_NAME AS LABEL,
        lm.GROSS_VALUE AS VALUE,
        NULL AS INFO
    FROM [stage].[BIZ_LINEITEM_MOD] lm
    WHERE lm.PARENT_SRC_KEY IS NOT NULL
) AS source_query;
```

- [ ] **Step 2: Commit**

```bash
git add ClaudeDevelopment/integrations/Bizon/03_Bizon001_Staging.sql
git commit -m "feat(bizon): add staging step T3-1 — LINEITEM_LINEITEM self-referencing link (Tier 3)"
```

---

## Task 8: Mapping Script (40 Entity Mappings)

**Files:**
- Create: `ClaudeDevelopment/integrations/Bizon/04_Bizon001_Mapping.sql`

All 40 entity mappings use the IF EXISTS UPDATE / ELSE INSERT pattern against `core.int_bizon001.EntityMappings`. Each mapping defines `source_table`, `source_columns` (JSON array with `name` and `hash` flag), `entity_columns` (JSON array of DV column names), and optionally `type2_columns`.

- [ ] **Step 1: Write all 25 hub mappings**

Hub mappings (hash:1 = business key, hash:0 = satellite attribute):

| # | entity_name | source_table | source_columns (hash:1 = BK) | entity_columns |
|---|---|---|---|---|
| 1 | LOCATION | BIZ_LOCATION | ITEM_SRC_KEY(1), LOCATION_NAME(0), LOCATION_ID(0), LEVEL_NAME(0), PARENT_ID(0), BOTTOM_LEVEL(0), MICROSERVICE_NAME(0), MICROSERVICE_ID(0) | HUB_ID, LOCATION_NAME, LOCATION_ID, LEVEL_NAME, PARENT_ID, BOTTOM_LEVEL, MICROSERVICE_NAME, MICROSERVICE_ID |
| 2-4 | PRODUCT ×3 | BIZ_PRODUCT | ITEM_SRC_KEY(1), + attrs per level | HUB_ID, PRODUCT_NAME, PRODUCT_ID, LEVEL_NAME, PARENT_ID, BOTTOM_LEVEL, MICROSERVICE_NAME, MICROSERVICE_ID |
| 5-6 | MOD ×2 | BIZ_MODIFIER | ITEM_SRC_KEY(1), + attrs per level | HUB_ID, MOD_NAME, MOD_ID, LEVEL_NAME, PARENT_ID, BOTTOM_LEVEL, MICROSERVICE_NAME, MICROSERVICE_ID |
| 7 | TAX | BIZ_TAX | ITEM_SRC_KEY(1), TAX_NAME(0), TAX_ID(0), TAX_MULTIPLIER(0), LEVEL_NAME(0), PARENT_ID(0) | HUB_ID, TAX_NAME, TAX_ID, TAX_MULTIPLIER, LEVEL_NAME, PARENT_ID |
| 8 | TENDER | BIZ_TENDER | ITEM_SRC_KEY(1), + attrs | HUB_ID, TENDER_NAME, TENDER_ID, LEVEL_NAME, PARENT_ID |
| 9 | REVCENTER | BIZ_REVCENTER | ITEM_SRC_KEY(1), REVC_NAME(0), REVC_ID(0), LEVEL_NAME(0), PARENT_ID(0), BOTTOM_LEVEL(0) | HUB_ID, REVC_NAME, REVC_ID, LEVEL_NAME, PARENT_ID, BOTTOM_LEVEL |
| 10 | CHANNEL | BIZ_CHANNEL | ITEM_SRC_KEY(1), + attrs | HUB_ID, CHANNEL_NAME, CHANNEL_ID, LEVEL_NAME, BOTTOM_LEVEL |
| 11 | DISCOUNT | BIZ_DISCOUNT | ITEM_SRC_KEY(1), + attrs | HUB_ID, DISCOUNT_NAME, DISCOUNT_ID, VALUE_TYPE, VALUE, IS_WASTE, LEVEL_NAME, PARENT_ID |
| 12 | SVCCHARGE | BIZ_SERVICECHARGE | ITEM_SRC_KEY(1), + attrs | HUB_ID, SVCCHARGE_NAME, SVC_ID, LEVEL_NAME, PARENT_ID |
| 13 | CUSTORDER | BIZ_CUSTORDER | HEADER_ID(1), + all 30 attrs | HUB_ID, GRAND_TOTAL, ... TRADING_DATE |
| 14-19 | LINEITEM ×6 | BIZ_LINEITEM / _MOD / _TAX / _DISCOUNT / _TENDER / _SVC | SRC_KEY(1), + attrs | HUB_ID, HEADER_ID, LINEITEM_TYPE, GROSS_VALUE, TAX_VALUE, NET_VALUE, QUANTITY, ... TRADING_DATE |
| 20 | BOOKING | BIZ_BOOKING | ITEM_SRC_KEY(1), + 10 attrs | HUB_ID, BOOKING_STATUS, PARTY_SIZE, BOOKING_DATETIME, BOOKING_DATE, DURATION_MINS, IS_WALKIN, DEPOSIT_AMOUNT, BOOKING_REFERENCE, ROOM_NUMBER, NOTES |
| 21 | INDIVIDUAL | BIZ_CUSTOMER | ITEM_SRC_KEY(1), + attrs | HUB_ID, FORENAME, SURNAME, ... |
| 22 | ADDRESS | BIZ_CUSTOMER | address key(1), + attrs | HUB_ID, ADDRESS, POSTCODE, ... |
| 23-24 | CONTACT ×2 | BIZ_CUSTOMER | contact key(1), + attrs | HUB_ID, CONTACT, CONTACT_TYPE, ... |

Refer to the design spec §4.1 for the exact column lists for each mapping. The `source_columns` JSON must have `"hash": 1` for the business key column and `"hash": 0` for all satellite attributes. Do NOT include `id` columns — let `DEFAULT NEWID()` generate them.

- [ ] **Step 2: Write all 15 link mappings**

Link mappings — all hub key columns have `hash: 1`:

| # | entity_name | source_table | source_columns (all hash:1) | entity_columns |
|---|---|---|---|---|
| 1 | CUSTORDER_LOCATION | BIZ_CUSTORDER_LOCATION | HEADER_ID(1), LOCATION_SRC_KEY(1) | CUSTORDER_HUB_ID, LOCATION_HUB_ID |
| 2 | CHANNEL_CUSTORDER | BIZ_CHANNEL_CUSTORDER | CHANNEL_SRC_KEY(1), HEADER_ID(1) | CHANNEL_HUB_ID, CUSTORDER_HUB_ID |
| 3 | CUSTORDER_LINEITEM | BIZ_CUSTORDER_LINEITEM | HEADER_ID(1), SRC_KEY(1) | CUSTORDER_HUB_ID, LINEITEM_HUB_ID |
| 4 | LINEITEM_PRODUCT | BIZ_LINEITEM_PRODUCT | SRC_KEY(1), PRODUCT_SRC_KEY(1) | LINEITEM_HUB_ID, PRODUCT_HUB_ID |
| 5 | LINEITEM_TAX | BIZ_LINEITEM_TAX_LNK | SRC_KEY(1), TAX_SRC_KEY(1) | LINEITEM_HUB_ID, TAX_HUB_ID |
| 6 | DISCOUNT_LINEITEM | BIZ_DISCOUNT_LINEITEM | DISCOUNT_SRC_KEY(1), SRC_KEY(1) | DISCOUNT_HUB_ID, LINEITEM_HUB_ID |
| 7 | LINEITEM_MOD | BIZ_LINEITEM_MOD_LNK | SRC_KEY(1), MOD_SRC_KEY(1) | LINEITEM_HUB_ID, MOD_HUB_ID |
| 8 | LINEITEM_TENDER | BIZ_LINEITEM_TENDER_LNK | SRC_KEY(1), TENDER_SRC_KEY(1) | LINEITEM_HUB_ID, TENDER_HUB_ID |
| 9 | LINEITEM_SVCCHARGE | BIZ_LINEITEM_SVC_LNK | SRC_KEY(1), SVC_SRC_KEY(1) | LINEITEM_HUB_ID, SVCCHARGE_HUB_ID |
| 10 | LINEITEM_LINEITEM | BIZ_LINEITEM_LINEITEM | PARENT_SRC_KEY(1), CHILD_SRC_KEY(1), LABEL(0), VALUE(0), INFO(0) | LINEITEM_HUB_ID, LINEITEM_HUB_ID, LABEL, VALUE, INFO |
| 11 | CUSTORDER_REVCENTER | BIZ_CUSTORDER_REVCENTER | HEADER_ID(1), REVCENTER_SRC_KEY(1) | CUSTORDER_HUB_ID, REVCENTER_HUB_ID |
| 12 | BOOKING_CUSTORDER | BIZ_BOOKING_CUSTORDER | BOOKING_SRC_KEY(1), HEADER_ID(1) | BOOKING_HUB_ID, CUSTORDER_HUB_ID |
| 13 | ADDRESS_INDIVIDUAL | BIZ_ADDRESS_INDIVIDUAL | ADDRESS_SRC_KEY(1), INDIVIDUAL_SRC_KEY(1) | ADDRESS_HUB_ID, INDIVIDUAL_HUB_ID |
| 14 | CONTACT_INDIVIDUAL | BIZ_CONTACT_INDIVIDUAL | CONTACT_SRC_KEY(1), INDIVIDUAL_SRC_KEY(1) | CONTACT_HUB_ID, INDIVIDUAL_HUB_ID |
| 15 | CUSTORDER_REFUND | BIZ_CUSTORDER_REFUND | HEADER_ID(1), REFUND_SRC_KEY(1) | CUSTORDER_HUB_ID, REFUND_HUB_ID |

**Note:** LINEITEM_LINEITEM (link #10) has SAT_LNK attributes (LABEL, VALUE, INFO) with `hash: 0`.

- [ ] **Step 3: Commit**

```bash
git add ClaudeDevelopment/integrations/Bizon/04_Bizon001_Mapping.sql
git commit -m "feat(bizon): add mapping script — 25 hub + 15 link entity mappings"
```

---

## Task 9: Final Script + QUERY_STATUS.md Update

**Files:**
- Create: `ClaudeDevelopment/integrations/Bizon/05_Bizon001_Final.sql`
- Modify: `ClaudeDevelopment/QUERY_STATUS.md`

- [ ] **Step 1: Write the Final script**

```sql
USE [core]
GO

DECLARE @return_value int

EXEC @return_value = [core].[UploadEntityMappings]
        @intSchema = N'int_bizon001'

SELECT 'Return Value' = @return_value

GO
```

- [ ] **Step 2: Update QUERY_STATUS.md**

Add entries for all 6 Bizon scripts (00-05) with status "Created — not deployed".

- [ ] **Step 3: Commit**

```bash
git add ClaudeDevelopment/integrations/Bizon/05_Bizon001_Final.sql ClaudeDevelopment/QUERY_STATUS.md
git commit -m "feat(bizon): add Final script + update QUERY_STATUS.md"
```

---

## Task 10: Documentation Updates

**Files:**
- Modify: `docs/integrations-reference.md` — add §7 Bizon section
- Modify: `docs/data-vault-reference.md` — add BOOKING v2, BOOKING_CUSTORDER to entity catalog
- Modify: `docs/data-pipeline.md` — add §5.6 Bizon to integration reference
- Modify: `CLAUDE.md` — add Bizon to integration table

- [ ] **Step 1: Add Bizon section to integrations-reference.md**

Add a new section after TROAP with complete documentation of:
- Integration metadata (name, schema, type, source API)
- All 26 DL tables with column lists
- All 36 staging steps
- All 40 entity mappings
- Implementation notes (JSON:API, string decimals, invoice-as-CUSTORDER)

- [ ] **Step 2: Update data-vault-reference.md**

Add BOOKING v2 to the hub entity catalog (§2), and BOOKING_CUSTORDER to the link catalog (§3). Update entity counts. Update the coverage matrix (§6) to show Bizon coverage.

- [ ] **Step 3: Update data-pipeline.md**

Add §5.6 Bizon (POS) with integration summary, DL table count, staging step count, entity mapping count, and key pipeline notes.

- [ ] **Step 4: Update CLAUDE.md integration table**

Add Bizon row to the integrations table:
```
| Bizon | POS | `Bizon/` | 26 | 36 (3 tiers) | 40 (25 hub, 15 link) |
```

- [ ] **Step 5: Commit**

```bash
git add docs/integrations-reference.md docs/data-vault-reference.md docs/data-pipeline.md CLAUDE.md
git commit -m "docs: add Bizon integration to reference documentation"
```

---

## Deployment Order

After all tasks are complete and scripts are validated:

1. **Script 00** — `00_Bizon_DataVaultEntities.sql` — run against core DB to add BOOKING v2 + BOOKING_CUSTORDER entities
2. **Script 01** — `01_Bizon001_INIT.sql` — registers integration in core.Integrations
3. **Manual step** — `EXEC [core].[sp_CreateIntegrationTables] @DatabaseName = 'core', @SchemaName = 'int_bizon001'`
4. **Script 02** — `02_Bizon001_DDL.sql` — DL table definitions into GlobalParameters
5. **Script 03** — `03_Bizon001_Staging.sql` — staging steps into StagingControl
6. **Script 04** — `04_Bizon001_Mapping.sql` — entity mappings into EntityMappings
7. **Script 05** — `05_Bizon001_Final.sql` — generates Load steps via UploadEntityMappings
8. **Per-org activation** — `EXEC [core].[MapOrganisationToIntegration] @OrganisationID = ?, @IntegrationID = ?`

**Prerequisite before Step 8:** Fetcher team must have JSON:API unravel capability deployed and configured for the Bizon001 integration.
