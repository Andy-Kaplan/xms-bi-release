# Square001 Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the Square POS integration (`int_square001`) — 5 SQL scripts delivering 22 DL tables, 39 staging steps, and 45 entity mappings.

**Architecture:** Single integration schema `int_square001` with IntegrationType `POS`. Follows the standard 5-file pattern (INIT → DDL → Staging → Mapping → Final). All scripts use upsert patterns for idempotent re-runs. Scripts authored in `ClaudeDevelopment/integrations/Square/`, promoted to `Square/` at release time.

**Tech Stack:** SQL Server (Managed Instance), T-SQL, upsert patterns (IF EXISTS UPDATE ELSE INSERT for GlobalParameters/StagingControl, MERGE or IF EXISTS for EntityMappings).

**Design Spec:** `ClaudeDevelopment/integrations/Square/2026-04-09-square-integration-design.md`

---

## File Structure

| File | Purpose | Estimated Lines |
|---|---|---|
| `ClaudeDevelopment/integrations/Square/01_Square001_INIT.sql` | Register integration + APIEndpointDetail skeleton | ~60 |
| `ClaudeDevelopment/integrations/Square/02_Square001_DDL.sql` | 22 DL table DDLs as STAGE_DDL GlobalParameters | ~600 |
| `ClaudeDevelopment/integrations/Square/03_Square001_Staging.sql` | 39 StagingControl upserts (Tiers 1-3) | ~2,800 |
| `ClaudeDevelopment/integrations/Square/04_Square001_Mapping.sql` | 45 EntityMappings upserts (26 hub + 19 link) | ~1,500 |
| `ClaudeDevelopment/integrations/Square/05_Square001_Final.sql` | EXEC UploadEntityMappings | ~15 |

**Prerequisite:** Before deploying to any environment, `sp_CreateIntegrationTables` must have been run to create the `int_square001` schema with its StagingControl, EntityMappings, and GlobalParameters tables. This is called manually between scripts 01 and 02.

---

## Task 1: INIT Script

**Files:**
- Create: `ClaudeDevelopment/integrations/Square/01_Square001_INIT.sql`

- [ ] **Step 1: Write the INIT script**

```sql
USE [core]
GO

DECLARE @return_value int

EXEC @return_value = [core].[AddIntegration]
        @IntegrationName = N'Square001',
        @IntegrationDisplayName = N'Square POS Version 1'

SELECT 'Return Value' = @return_value

GO


UPDATE [core].[Integrations] SET
[APIEndpointDetail] = '{
    "api_info": {
        "source": "square",
        "version": "v2",
        "base_url": "https://connect.squareup.com/v2"
    },
    "endpoints": {
        "locations": {
            "description": "Store/site location data",
            "endpoint": "locations",
            "unique_identifier": "id",
            "request_method": "GET"
        },
        "orders": {
            "description": "Order transactions with line items",
            "endpoint": "orders/search",
            "unravel_properties": {
                "line_items": ["explode"],
                "tenders": ["explode"],
                "fulfillments": ["explode"],
                "service_charges": ["explode"]
            },
            "lists_obj_after_unravel": [
                {"line_items.modifiers": null},
                {"line_items.applied_taxes": null},
                {"line_items.applied_discounts": null}
            ],
            "unique_identifier": "id",
            "request_method": "POST"
        },
        "catalog": {
            "description": "Product catalog (items, variations, categories, taxes, discounts, modifiers)",
            "endpoint": "catalog/search",
            "unique_identifier": "id",
            "request_method": "POST"
        },
        "inventory_counts": {
            "description": "Current inventory stock levels",
            "endpoint": "inventory/counts/batch-retrieve",
            "unique_identifier": "catalog_object_id",
            "request_method": "POST"
        },
        "inventory_changes": {
            "description": "Inventory adjustments, physical counts, transfers",
            "endpoint": "inventory/changes/batch-retrieve",
            "unique_identifier": "id",
            "request_method": "POST"
        },
        "refunds": {
            "description": "Payment refunds",
            "endpoint": "refunds",
            "unique_identifier": "id",
            "request_method": "GET"
        },
        "customers": {
            "description": "Customer profiles",
            "endpoint": "customers/search",
            "unique_identifier": "id",
            "request_method": "POST"
        },
        "team_members": {
            "description": "Employee/team member records",
            "endpoint": "team-members/search",
            "unique_identifier": "id",
            "request_method": "POST"
        },
        "shifts": {
            "description": "Labor shift records",
            "endpoint": "labor/shifts/search",
            "unique_identifier": "id",
            "request_method": "POST"
        }
    },
    "pagination": {
        "pagination_value_key": "cursor",
        "pagination_flag_key": null
    }
}',
[IntegrationType] = 'POS'

WHERE [IntegrationName] = 'Square001'
```

**Note:** The `APIEndpointDetail` JSON is a skeleton for the fetcher team. The exact `unravel_properties` and `lists_obj_after_unravel` structures will need refinement when the fetcher is configured against real Square API responses.

- [ ] **Step 2: Commit**

```bash
git add ClaudeDevelopment/integrations/Square/01_Square001_INIT.sql
git commit -m "feat(square): add INIT script — register Square001 integration"
```

---

## Task 2: DDL Script (22 DL Tables)

**Files:**
- Create: `ClaudeDevelopment/integrations/Square/02_Square001_DDL.sql`

Every DL table follows the same pattern — all data columns `[nvarchar](max) NULL`, plus the two mandatory system columns at the end. The upsert pattern checks `GlobalParameters` for existing `STAGE_DDL` records.

- [ ] **Step 1: Write the DDL script header and first table (DL_ORDERS)**

The pattern for every table (showing DL_ORDERS as the first example):

```sql
-- Square001 DL Table DDL Export
-- Schema: int_square001
-- Total Tables: 22

-- Table: DL_ORDERS
IF EXISTS (SELECT 1 FROM core.[int_square001].[GlobalParameters] WHERE ParameterKey = N'DL_ORDERS' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_square001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_square001].[DL_ORDERS](
	[id] [nvarchar](max) NULL,
	[location_id] [nvarchar](max) NULL,
	[state] [nvarchar](max) NULL,
	[source_name] [nvarchar](max) NULL,
	[created_at] [nvarchar](max) NULL,
	[updated_at] [nvarchar](max) NULL,
	[closed_at] [nvarchar](max) NULL,
	[total_money_amount] [nvarchar](max) NULL,
	[total_money_currency] [nvarchar](max) NULL,
	[total_tax_money_amount] [nvarchar](max) NULL,
	[total_discount_money_amount] [nvarchar](max) NULL,
	[total_tip_money_amount] [nvarchar](max) NULL,
	[total_service_charge_money_amount] [nvarchar](max) NULL,
	[net_amount_due_money_amount] [nvarchar](max) NULL,
	[ticket_name] [nvarchar](max) NULL,
	[customer_id] [nvarchar](max) NULL,
	[reference_id] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL,
	[INT_FETCH_DATE] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]',
        Description = N'DL_ORDERS',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_ORDERS' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_square001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_ORDERS', N'CREATE TABLE [int_square001].[DL_ORDERS](
	[id] [nvarchar](max) NULL,
	[location_id] [nvarchar](max) NULL,
	[state] [nvarchar](max) NULL,
	[source_name] [nvarchar](max) NULL,
	[created_at] [nvarchar](max) NULL,
	[updated_at] [nvarchar](max) NULL,
	[closed_at] [nvarchar](max) NULL,
	[total_money_amount] [nvarchar](max) NULL,
	[total_money_currency] [nvarchar](max) NULL,
	[total_tax_money_amount] [nvarchar](max) NULL,
	[total_discount_money_amount] [nvarchar](max) NULL,
	[total_tip_money_amount] [nvarchar](max) NULL,
	[total_service_charge_money_amount] [nvarchar](max) NULL,
	[net_amount_due_money_amount] [nvarchar](max) NULL,
	[ticket_name] [nvarchar](max) NULL,
	[customer_id] [nvarchar](max) NULL,
	[reference_id] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL,
	[INT_FETCH_DATE] [datetime2](7) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]', 'STRING', 'STAGE_DDL', N'DL_ORDERS', 1, SYSTEM_USER, GETDATE(), 1);
END
GO
```

- [ ] **Step 2: Write the remaining 21 DL table DDLs**

Each follows the identical pattern above. The tables and their columns (all `[nvarchar](max) NULL` except system columns):

**Orders family (7 remaining):**

`DL_ORDERS_LINEITEMS`: `order_id`, `location_id`, `uid`, `name`, `quantity`, `catalog_object_id`, `catalog_version`, `variation_name`, `item_type`, `base_price_money_amount`, `base_price_money_currency`, `gross_sales_money_amount`, `total_tax_money_amount`, `total_discount_money_amount`, `total_money_amount`, `note`

`DL_ORDERS_LINEITEMS_MODIFIERS`: `order_id`, `location_id`, `lineitem_uid`, `uid`, `catalog_object_id`, `name`, `quantity`, `base_price_money_amount`, `total_price_money_amount`

`DL_ORDERS_LINEITEMS_TAXES`: `order_id`, `location_id`, `lineitem_uid`, `tax_uid`, `catalog_object_id`, `name`, `type`, `percentage`, `applied_money_amount`

`DL_ORDERS_LINEITEMS_DISCOUNTS`: `order_id`, `location_id`, `lineitem_uid`, `discount_uid`, `catalog_object_id`, `name`, `type`, `percentage`, `amount_money_amount`, `applied_money_amount`, `scope`

`DL_ORDERS_SERVICECHARGES`: `order_id`, `location_id`, `uid`, `name`, `catalog_object_id`, `percentage`, `amount_money_amount`, `total_money_amount`, `type`, `taxable`, `calculation_phase`

`DL_ORDERS_TENDERS`: `order_id`, `location_id`, `id`, `type`, `amount_money_amount`, `tip_money_amount`, `processing_fee_money_amount`, `customer_id`, `payment_id`, `created_at`, `note`

`DL_ORDERS_FULFILLMENTS`: `order_id`, `location_id`, `uid`, `type`, `state`, `pickup_at`, `deliver_at`, `schedule_type`

**Catalog family (7):**

`DL_CATALOG_ITEMS`: `id`, `updated_at`, `version`, `is_deleted`, `item_data_name`, `item_data_description`, `item_data_category_id`, `item_data_product_type`

`DL_CATALOG_ITEMVARIATIONS`: `id`, `updated_at`, `version`, `is_deleted`, `item_variation_data_item_id`, `item_variation_data_name`, `item_variation_data_sku`, `item_variation_data_upc`, `item_variation_data_pricing_type`, `item_variation_data_price_money_amount`, `item_variation_data_price_money_currency`, `item_variation_data_track_inventory`, `item_variation_data_measurement_unit_id`

`DL_CATALOG_CATEGORIES`: `id`, `updated_at`, `is_deleted`, `category_data_name`, `category_data_parent_category_id`, `category_data_is_top_level`

`DL_CATALOG_TAXES`: `id`, `updated_at`, `is_deleted`, `tax_data_name`, `tax_data_percentage`, `tax_data_inclusion_type`, `tax_data_applies_to_custom_amounts`

`DL_CATALOG_DISCOUNTS`: `id`, `updated_at`, `is_deleted`, `discount_data_name`, `discount_data_discount_type`, `discount_data_percentage`, `discount_data_amount_money_amount`

`DL_CATALOG_MODIFIERLISTS`: `id`, `updated_at`, `is_deleted`, `modifier_list_data_name`, `modifier_list_data_selection_type`

`DL_CATALOG_MODIFIERS`: `id`, `updated_at`, `is_deleted`, `modifier_data_name`, `modifier_data_modifier_list_id`, `modifier_data_price_money_amount`

**Locations (1):**

`DL_LOCATIONS`: `id`, `name`, `business_name`, `type`, `status`, `currency`, `country`, `timezone`, `address_line_1`, `address_line_2`, `locality`, `administrative_district_level_1`, `postal_code`, `phone_number`, `business_email`, `merchant_id`, `created_at`

**Inventory (2):**

`DL_INVENTORY_COUNTS`: `catalog_object_id`, `catalog_object_type`, `state`, `location_id`, `quantity`, `calculated_at`

`DL_INVENTORY_CHANGES`: `type`, `id`, `catalog_object_id`, `location_id`, `from_state`, `to_state`, `quantity`, `occurred_at`, `created_at`, `reference_id`, `source_application_name`, `employee_id`, `team_member_id`, `transaction_id`

**Refunds (1):**

`DL_REFUNDS`: `id`, `payment_id`, `order_id`, `location_id`, `status`, `amount_money_amount`, `amount_money_currency`, `reason`, `created_at`, `updated_at`

**Customers (1):**

`DL_CUSTOMERS`: `id`, `created_at`, `updated_at`, `given_name`, `family_name`, `email_address`, `phone_number`, `company_name`, `address_line_1`, `address_line_2`, `locality`, `postal_code`, `country`, `reference_id`, `note`, `birthday`

**Workforce (2):**

`DL_TEAM_MEMBERS`: `id`, `status`, `given_name`, `family_name`, `email_address`, `phone_number`, `created_at`, `updated_at`, `is_owner`

`DL_SHIFTS`: `id`, `team_member_id`, `location_id`, `start_at`, `end_at`, `status`, `wage_title`, `wage_hourly_rate_amount`, `wage_hourly_rate_currency`, `wage_tip_eligible`, `created_at`, `updated_at`

- [ ] **Step 3: Commit**

```bash
git add ClaudeDevelopment/integrations/Square/02_Square001_DDL.sql
git commit -m "feat(square): add DDL script — 22 DL table definitions"
```

---

## Task 3: Staging Script — Tier 1 Dimension Steps (8 steps)

**Files:**
- Create: `ClaudeDevelopment/integrations/Square/03_Square001_Staging.sql`

Every StagingControl upsert follows the NCRAloha pattern: IF EXISTS UPDATE ELSE INSERT, with `query_sql` containing the idempotent DROP IF EXISTS + SELECT INTO pattern. All `query_sql` values use escaped single quotes (`''`).

- [ ] **Step 1: Write the script header and Location step**

```sql
-- Square001 Staging Control Steps
-- Schema: int_square001
-- Total Steps: 39

-- ============================================
-- TIER 1 — Dimension Steps (8)
-- ============================================

-- Step: Location (Tier 1)
IF EXISTS (SELECT 1 FROM [core].[int_square001].[StagingControl] WHERE [step_name] = N'Location')
BEGIN
    UPDATE [core].[int_square001].[StagingControl]
    SET [staging_table] = N'SQR_LOCATION',
        [query_sql] = N'IF OBJECT_ID(''stage.SQR_LOCATION'', ''U'') IS NOT NULL
    DROP TABLE [stage].[SQR_LOCATION];

SELECT * INTO [stage].[SQR_LOCATION]
FROM (
SELECT
    [id] AS ITEM_SRC_KEY
    ,[name] AS LOCATION_NAME
    ,[id] AS LOCATION_ID
    ,''BOTTOM'' AS LEVEL_NAME
    ,NULL AS PARENT_ID
    ,1 AS BOTTOM_LEVEL
    ,NULL AS MICROSERVICE_NAME
    ,NULL AS MICROSERVICE_ID
FROM (
    SELECT *
        ,ROW_NUMBER() OVER(PARTITION BY [id] ORDER BY [LOADTS_UTC] DESC) AS RN
    FROM [int_square001].[DL_LOCATIONS]
    WHERE [status] = ''ACTIVE''
) sub
WHERE RN = 1
) AS source_query;',
        [tier] = 1,
        [step_type] = N'Staging',
        [exclude] = 0,
        [description] = N'Square location dimension from ListLocations API',
        [depends_on_steps] = NULL,
        [retry_count] = 3,
        [timeout_minutes] = 30,
        [staging_columns] = N'["ITEM_SRC_KEY", "LOCATION_NAME", "LOCATION_ID", "LEVEL_NAME", "PARENT_ID", "BOTTOM_LEVEL", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
        [updated_at] = GETDATE()
    WHERE [step_name] = N'Location';
END
ELSE
BEGIN
    INSERT INTO [core].[int_square001].[StagingControl]
    ([step_name], [staging_table], [query_sql], [tier], [step_type], [exclude],
     [description], [depends_on_steps], [retry_count], [timeout_minutes], [staging_columns], [created_at], [updated_at])
    VALUES (N'Location', N'SQR_LOCATION', N'IF OBJECT_ID(''stage.SQR_LOCATION'', ''U'') IS NOT NULL
    DROP TABLE [stage].[SQR_LOCATION];

SELECT * INTO [stage].[SQR_LOCATION]
FROM (
SELECT
    [id] AS ITEM_SRC_KEY
    ,[name] AS LOCATION_NAME
    ,[id] AS LOCATION_ID
    ,''BOTTOM'' AS LEVEL_NAME
    ,NULL AS PARENT_ID
    ,1 AS BOTTOM_LEVEL
    ,NULL AS MICROSERVICE_NAME
    ,NULL AS MICROSERVICE_ID
FROM (
    SELECT *
        ,ROW_NUMBER() OVER(PARTITION BY [id] ORDER BY [LOADTS_UTC] DESC) AS RN
    FROM [int_square001].[DL_LOCATIONS]
    WHERE [status] = ''ACTIVE''
) sub
WHERE RN = 1
) AS source_query;', 1, N'Staging', 0, N'Square location dimension from ListLocations API', NULL, 3, 30, N'["ITEM_SRC_KEY", "LOCATION_NAME", "LOCATION_ID", "LEVEL_NAME", "PARENT_ID", "BOTTOM_LEVEL", "MICROSERVICE_NAME", "MICROSERVICE_ID"]', GETDATE(), GETDATE());
END
GO
```

- [ ] **Step 2: Write the Product step (3-level hierarchy via UNION ALL)**

```sql
-- Step: Product (Tier 1)
-- Three-level hierarchy: Category (TOP) → Item (MIDDLE_1) → Variation (BOTTOM)
```

`query_sql` content (escaped for StagingControl):

```sql
IF OBJECT_ID(''stage.SQR_PRODUCT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[SQR_PRODUCT];

SELECT * INTO [stage].[SQR_PRODUCT]
FROM (
SELECT ITEM_SRC_KEY, PRODUCT_NAME, PRODUCT_ID, LEVEL_NAME, PARENT_ID, BOTTOM_LEVEL,
       NULL AS MICROSERVICE_NAME, NULL AS MICROSERVICE_ID
FROM (
    -- BOTTOM: Catalog Item Variations
    SELECT
        v.[id] AS ITEM_SRC_KEY
        ,COALESCE(v.[item_variation_data_name], i.[item_data_name]) AS PRODUCT_NAME
        ,v.[id] AS PRODUCT_ID
        ,''BOTTOM'' AS LEVEL_NAME
        ,v.[item_variation_data_item_id] AS PARENT_ID
        ,1 AS BOTTOM_LEVEL
        ,ROW_NUMBER() OVER(PARTITION BY v.[id] ORDER BY v.[LOADTS_UTC] DESC) AS RN
    FROM [int_square001].[DL_CATALOG_ITEMVARIATIONS] v
    LEFT JOIN [int_square001].[DL_CATALOG_ITEMS] i ON v.[item_variation_data_item_id] = i.[id]
    WHERE (v.[is_deleted] = ''false'' OR v.[is_deleted] IS NULL)

    UNION ALL

    -- MIDDLE_1: Catalog Items
    SELECT
        [id] AS ITEM_SRC_KEY
        ,[item_data_name] AS PRODUCT_NAME
        ,[id] AS PRODUCT_ID
        ,''MIDDLE_1'' AS LEVEL_NAME
        ,[item_data_category_id] AS PARENT_ID
        ,0 AS BOTTOM_LEVEL
        ,ROW_NUMBER() OVER(PARTITION BY [id] ORDER BY [LOADTS_UTC] DESC) AS RN
    FROM [int_square001].[DL_CATALOG_ITEMS]
    WHERE ([is_deleted] = ''false'' OR [is_deleted] IS NULL)

    UNION ALL

    -- TOP: Catalog Categories
    SELECT
        [id] AS ITEM_SRC_KEY
        ,[category_data_name] AS PRODUCT_NAME
        ,[id] AS PRODUCT_ID
        ,''TOP'' AS LEVEL_NAME
        ,[category_data_parent_category_id] AS PARENT_ID
        ,0 AS BOTTOM_LEVEL
        ,ROW_NUMBER() OVER(PARTITION BY [id] ORDER BY [LOADTS_UTC] DESC) AS RN
    FROM [int_square001].[DL_CATALOG_CATEGORIES]
    WHERE ([is_deleted] = ''false'' OR [is_deleted] IS NULL)
) sub
WHERE RN = 1
) AS source_query;
```

Staging table: `SQR_PRODUCT`. Columns: `["ITEM_SRC_KEY", "PRODUCT_NAME", "PRODUCT_ID", "LEVEL_NAME", "PARENT_ID", "BOTTOM_LEVEL", "MICROSERVICE_NAME", "MICROSERVICE_ID"]`

- [ ] **Step 3: Write the remaining 6 dimension steps**

Each follows the same upsert pattern. Here are the `query_sql` bodies:

**Tax** → `SQR_TAX` from `DL_CATALOG_TAXES`:
```sql
IF OBJECT_ID(''stage.SQR_TAX'', ''U'') IS NOT NULL
    DROP TABLE [stage].[SQR_TAX];

SELECT * INTO [stage].[SQR_TAX]
FROM (
SELECT
    [id] AS ITEM_SRC_KEY
    ,[tax_data_name] AS TAX_NAME
    ,[id] AS TAX_ID
    ,CAST(CAST([tax_data_percentage] AS DECIMAL(18,6)) / 100.0 AS NVARCHAR(255)) AS TAX_MULTIPLIER
    ,''BOTTOM'' AS LEVEL_NAME
    ,NULL AS PARENT_ID
FROM (
    SELECT *, ROW_NUMBER() OVER(PARTITION BY [id] ORDER BY [LOADTS_UTC] DESC) AS RN
    FROM [int_square001].[DL_CATALOG_TAXES]
    WHERE ([is_deleted] = ''false'' OR [is_deleted] IS NULL)
) sub WHERE RN = 1
) AS source_query;
```
Columns: `["ITEM_SRC_KEY", "TAX_NAME", "TAX_ID", "TAX_MULTIPLIER", "LEVEL_NAME", "PARENT_ID"]`

**Discount** → `SQR_DISCOUNT` from `DL_CATALOG_DISCOUNTS`:
```sql
IF OBJECT_ID(''stage.SQR_DISCOUNT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[SQR_DISCOUNT];

SELECT * INTO [stage].[SQR_DISCOUNT]
FROM (
SELECT
    [id] AS ITEM_SRC_KEY
    ,[discount_data_name] AS DISCOUNT_NAME
    ,[id] AS DISCOUNT_ID
    ,[discount_data_discount_type] AS VALUE_TYPE
    ,COALESCE([discount_data_percentage],
        CAST(CAST([discount_data_amount_money_amount] AS BIGINT) / 100.0 AS NVARCHAR(255))) AS VALUE
    ,0 AS IS_WASTE
    ,''BOTTOM'' AS LEVEL_NAME
    ,NULL AS PARENT_ID
FROM (
    SELECT *, ROW_NUMBER() OVER(PARTITION BY [id] ORDER BY [LOADTS_UTC] DESC) AS RN
    FROM [int_square001].[DL_CATALOG_DISCOUNTS]
    WHERE ([is_deleted] = ''false'' OR [is_deleted] IS NULL)
) sub WHERE RN = 1
) AS source_query;
```
Columns: `["ITEM_SRC_KEY", "DISCOUNT_NAME", "DISCOUNT_ID", "VALUE_TYPE", "VALUE", "IS_WASTE", "LEVEL_NAME", "PARENT_ID"]`

**Modifier** → `SQR_MODIFIER` from `DL_CATALOG_MODIFIERS` + `DL_CATALOG_MODIFIERLISTS` (2-level UNION ALL):
```sql
IF OBJECT_ID(''stage.SQR_MODIFIER'', ''U'') IS NOT NULL
    DROP TABLE [stage].[SQR_MODIFIER];

SELECT * INTO [stage].[SQR_MODIFIER]
FROM (
SELECT ITEM_SRC_KEY, MOD_NAME, MOD_ID, LEVEL_NAME, PARENT_ID, BOTTOM_LEVEL,
       NULL AS MICROSERVICE_NAME, NULL AS MICROSERVICE_ID
FROM (
    -- BOTTOM: Individual modifiers
    SELECT
        m.[id] AS ITEM_SRC_KEY
        ,m.[modifier_data_name] AS MOD_NAME
        ,m.[id] AS MOD_ID
        ,''BOTTOM'' AS LEVEL_NAME
        ,m.[modifier_data_modifier_list_id] AS PARENT_ID
        ,1 AS BOTTOM_LEVEL
        ,ROW_NUMBER() OVER(PARTITION BY m.[id] ORDER BY m.[LOADTS_UTC] DESC) AS RN
    FROM [int_square001].[DL_CATALOG_MODIFIERS] m
    WHERE (m.[is_deleted] = ''false'' OR m.[is_deleted] IS NULL)

    UNION ALL

    -- TOP: Modifier lists
    SELECT
        [id] AS ITEM_SRC_KEY
        ,[modifier_list_data_name] AS MOD_NAME
        ,[id] AS MOD_ID
        ,''TOP'' AS LEVEL_NAME
        ,NULL AS PARENT_ID
        ,0 AS BOTTOM_LEVEL
        ,ROW_NUMBER() OVER(PARTITION BY [id] ORDER BY [LOADTS_UTC] DESC) AS RN
    FROM [int_square001].[DL_CATALOG_MODIFIERLISTS]
    WHERE ([is_deleted] = ''false'' OR [is_deleted] IS NULL)
) sub WHERE RN = 1
) AS source_query;
```
Columns: `["ITEM_SRC_KEY", "MOD_NAME", "MOD_ID", "LEVEL_NAME", "PARENT_ID", "BOTTOM_LEVEL", "MICROSERVICE_NAME", "MICROSERVICE_ID"]`

**Channel** → `SQR_CHANNEL` from `DL_ORDERS`:
```sql
IF OBJECT_ID(''stage.SQR_CHANNEL'', ''U'') IS NOT NULL
    DROP TABLE [stage].[SQR_CHANNEL];

SELECT * INTO [stage].[SQR_CHANNEL]
FROM (
SELECT DISTINCT
    [source_name] AS ITEM_SRC_KEY
    ,[source_name] AS CHANNEL_NAME
    ,[source_name] AS CHANNEL_ID
    ,''BOTTOM'' AS LEVEL_NAME
    ,1 AS BOTTOM_LEVEL
FROM [int_square001].[DL_ORDERS]
WHERE [source_name] IS NOT NULL
) AS source_query;
```
Columns: `["ITEM_SRC_KEY", "CHANNEL_NAME", "CHANNEL_ID", "LEVEL_NAME", "BOTTOM_LEVEL"]`

**Service Charge** → `SQR_SERVICECHARGE` from `DL_ORDERS_SERVICECHARGES`:
```sql
IF OBJECT_ID(''stage.SQR_SERVICECHARGE'', ''U'') IS NOT NULL
    DROP TABLE [stage].[SQR_SERVICECHARGE];

SELECT * INTO [stage].[SQR_SERVICECHARGE]
FROM (
SELECT DISTINCT
    [name] AS ITEM_SRC_KEY
    ,[name] AS SVCCHARGE_NAME
    ,[name] AS SVC_ID
    ,''BOTTOM'' AS LEVEL_NAME
    ,NULL AS PARENT_ID
FROM [int_square001].[DL_ORDERS_SERVICECHARGES]
WHERE [name] IS NOT NULL
) AS source_query;
```
Columns: `["ITEM_SRC_KEY", "SVCCHARGE_NAME", "SVC_ID", "LEVEL_NAME", "PARENT_ID"]`

**Occasion** → `SQR_OCCASION` from `DL_ORDERS_FULFILLMENTS` + synthetic DINE_IN row:
```sql
IF OBJECT_ID(''stage.SQR_OCCASION'', ''U'') IS NOT NULL
    DROP TABLE [stage].[SQR_OCCASION];

SELECT * INTO [stage].[SQR_OCCASION]
FROM (
SELECT DISTINCT
    occ_name AS ITEM_SRC_KEY
    ,occ_name AS OCCASION_NAME
    ,occ_name AS OCCASSION_ID
    ,''BOTTOM'' AS LEVEL_NAME
    ,NULL AS PARENT_ID
    ,1 AS BOTTOM_LEVEL
FROM (
    SELECT DISTINCT [type] AS occ_name
    FROM [int_square001].[DL_ORDERS_FULFILLMENTS]
    WHERE [type] IS NOT NULL
    UNION
    SELECT ''DINE_IN'' AS occ_name
) sub
) AS source_query;
```
Columns: `["ITEM_SRC_KEY", "OCCASION_NAME", "OCCASSION_ID", "LEVEL_NAME", "PARENT_ID", "BOTTOM_LEVEL"]`

- [ ] **Step 4: Commit**

```bash
git add ClaudeDevelopment/integrations/Square/03_Square001_Staging.sql
git commit -m "feat(square): add staging Tier 1 dimension steps (8)"
```

---

## Task 4: Staging Script — Tier 1 Transactional Steps (7 steps)

**Files:**
- Modify: `ClaudeDevelopment/integrations/Square/03_Square001_Staging.sql`

Append to the staging script. These are the POS transactional staging steps.

- [ ] **Step 1: Write Customer Order step**

`query_sql` for `SQR_CUSTORDER` from `DL_ORDERS`:
```sql
IF OBJECT_ID(''stage.SQR_CUSTORDER'', ''U'') IS NOT NULL
    DROP TABLE [stage].[SQR_CUSTORDER];

SELECT * INTO [stage].[SQR_CUSTORDER]
FROM (
SELECT
    CONCAT_WS(''-'', [location_id], [id]) AS HEADER_ID
    ,[location_id] AS LOCATION_ID
    ,CAST(CAST([total_money_amount] AS BIGINT) / 100.0 AS NVARCHAR(255)) AS GRAND_TOTAL
    ,CAST(CAST([total_money_amount] AS BIGINT) / 100.0 AS NVARCHAR(255)) AS GROSS_SALES
    ,CAST((CAST([total_money_amount] AS BIGINT) - CAST(ISNULL([total_tax_money_amount],''0'') AS BIGINT)) / 100.0 AS NVARCHAR(255)) AS NET_SALES
    ,CAST(CAST(ISNULL([total_tax_money_amount],''0'') AS BIGINT) / 100.0 AS NVARCHAR(255)) AS TAX_TOTAL
    ,CAST(CAST(ISNULL([total_discount_money_amount],''0'') AS BIGINT) / 100.0 AS NVARCHAR(255)) AS DISCOUNT_GROSS
    ,CAST(CAST(ISNULL([total_service_charge_money_amount],''0'') AS BIGINT) / 100.0 AS NVARCHAR(255)) AS SVC_CHARGE_TOTAL
    ,CASE WHEN [customer_id] IS NOT NULL THEN ''1'' ELSE NULL END AS GUEST_COUNT
    ,NULL AS ITEM_COUNT
    ,[created_at] AS OPEN_TIME
    ,[closed_at] AS CLOSE_TIME
    ,[created_at] AS ORDER_DATE
    ,COALESCE([ticket_name], ''Square Order '') AS ORDER_INFO
    ,[reference_id] AS EXTERNAL_REFERENCE
    ,CAST(CAST(COALESCE([closed_at], [created_at]) AS DATE) AS NVARCHAR(255)) AS TRADING_DATE
    ,[state] AS ORDER_STATUS
    ,CASE WHEN [net_amount_due_money_amount] = ''0'' THEN ''PAID''
          WHEN [net_amount_due_money_amount] IS NULL THEN ''PAID''
          ELSE ''UNPAID'' END AS PAYMENT_STATUS
    ,CAST(CAST(ISNULL([total_money_amount],''0'') AS BIGINT) / 100.0 AS NVARCHAR(255)) AS TENDERED_SALES
    ,[source_name] AS CHANNEL_NAME
    ,COALESCE([customer_id], '''') AS CUSTOMER_REF
FROM [int_square001].[DL_ORDERS]
WHERE [state] IN (''COMPLETED'', ''CANCELED'')
) AS source_query;
```
Staging table: `SQR_CUSTORDER`. Tier 1.
Columns: `["HEADER_ID", "LOCATION_ID", "GRAND_TOTAL", "GROSS_SALES", "NET_SALES", "TAX_TOTAL", "DISCOUNT_GROSS", "SVC_CHARGE_TOTAL", "GUEST_COUNT", "ITEM_COUNT", "OPEN_TIME", "CLOSE_TIME", "ORDER_DATE", "ORDER_INFO", "EXTERNAL_REFERENCE", "TRADING_DATE", "ORDER_STATUS", "PAYMENT_STATUS", "TENDERED_SALES", "CHANNEL_NAME", "CUSTOMER_REF"]`

- [ ] **Step 2: Write Line Item step (PROD type)**

`query_sql` for `SQR_LINEITEM` from `DL_ORDERS_LINEITEMS`:
```sql
IF OBJECT_ID(''stage.SQR_LINEITEM'', ''U'') IS NOT NULL
    DROP TABLE [stage].[SQR_LINEITEM];

SELECT * INTO [stage].[SQR_LINEITEM]
FROM (
SELECT
    CONCAT_WS(''-'', li.[location_id], li.[order_id], li.[uid], ''PROD'') AS SRC_KEY
    ,CONCAT_WS(''-'', li.[location_id], li.[order_id]) AS HEADER_ID
    ,''PROD'' AS LINEITEM_TYPE
    ,CAST(CAST(ISNULL(li.[gross_sales_money_amount],''0'') AS BIGINT) / 100.0 AS NVARCHAR(255)) AS GROSS_VALUE
    ,CAST(CAST(ISNULL(li.[total_tax_money_amount],''0'') AS BIGINT) / 100.0 AS NVARCHAR(255)) AS TAX_VALUE
    ,CAST(CAST(ISNULL(li.[total_money_amount],''0'') AS BIGINT) / 100.0 AS NVARCHAR(255)) AS NET_VALUE
    ,CAST(CAST(li.[quantity] AS DECIMAL(18,4)) AS NVARCHAR(255)) AS QUANTITY
    ,NULL AS QUANTITY_INV
    ,o.[created_at] AS LINEITEM_TIMESTAMP
    ,CAST(CAST(COALESCE(o.[closed_at], o.[created_at]) AS DATE) AS NVARCHAR(255)) AS ITEM_DATE
    ,CAST(CAST(COALESCE(o.[closed_at], o.[created_at]) AS DATE) AS NVARCHAR(255)) AS ORDER_DATE
    ,CASE WHEN o.[state] = ''CANCELED'' THEN ''1'' ELSE ''0'' END AS VOID_FLAG
    ,li.[uid] AS LINE_ID
    ,NULL AS LINE_ORDER
    ,CAST(CAST(COALESCE(o.[closed_at], o.[created_at]) AS DATE) AS NVARCHAR(255)) AS TRADING_DATE
    ,li.[catalog_object_id] AS PRODUCT_SRC_KEY
    ,li.[location_id] AS LOCATION_ID
    ,li.[order_id] AS ORDER_ID
    ,li.[uid] AS LINEITEM_UID
FROM [int_square001].[DL_ORDERS_LINEITEMS] li
JOIN [int_square001].[DL_ORDERS] o ON li.[order_id] = o.[id] AND li.[location_id] = o.[location_id]
WHERE o.[state] IN (''COMPLETED'', ''CANCELED'')
) AS source_query;
```
Staging table: `SQR_LINEITEM`. Tier 1. `depends_on_steps = NULL`.
Columns: `["SRC_KEY", "HEADER_ID", "LINEITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "QUANTITY_INV", "LINEITEM_TIMESTAMP", "ITEM_DATE", "ORDER_DATE", "VOID_FLAG", "LINE_ID", "LINE_ORDER", "TRADING_DATE", "PRODUCT_SRC_KEY", "LOCATION_ID", "ORDER_ID", "LINEITEM_UID"]`

- [ ] **Step 3: Write the remaining 5 transactional steps**

Each follows the same upsert pattern. Here are the `query_sql` bodies:

**Tender** → `SQR_TENDER` from `DL_ORDERS_TENDERS`:
```sql
IF OBJECT_ID(''stage.SQR_TENDER'', ''U'') IS NOT NULL
    DROP TABLE [stage].[SQR_TENDER];

SELECT * INTO [stage].[SQR_TENDER]
FROM (
SELECT
    CONCAT_WS(''-'', t.[location_id], t.[order_id], t.[id], ''TENDER'') AS SRC_KEY
    ,CONCAT_WS(''-'', t.[location_id], t.[order_id]) AS HEADER_ID
    ,''TENDER'' AS LINEITEM_TYPE
    ,CAST(CAST(ISNULL(t.[amount_money_amount],''0'') AS BIGINT) / 100.0 AS NVARCHAR(255)) AS GROSS_VALUE
    ,''0'' AS TAX_VALUE
    ,CAST(CAST(ISNULL(t.[amount_money_amount],''0'') AS BIGINT) / 100.0 AS NVARCHAR(255)) AS NET_VALUE
    ,''1'' AS QUANTITY
    ,NULL AS QUANTITY_INV
    ,t.[created_at] AS LINEITEM_TIMESTAMP
    ,CAST(CAST(COALESCE(o.[closed_at], o.[created_at]) AS DATE) AS NVARCHAR(255)) AS ITEM_DATE
    ,CAST(CAST(COALESCE(o.[closed_at], o.[created_at]) AS DATE) AS NVARCHAR(255)) AS ORDER_DATE
    ,''0'' AS VOID_FLAG
    ,t.[id] AS LINE_ID
    ,NULL AS LINE_ORDER
    ,CAST(CAST(COALESCE(o.[closed_at], o.[created_at]) AS DATE) AS NVARCHAR(255)) AS TRADING_DATE
    ,t.[type] AS TENDER_TYPE
    ,t.[type] AS TENDER_NAME
    ,CAST(CAST(ISNULL(t.[tip_money_amount],''0'') AS BIGINT) / 100.0 AS NVARCHAR(255)) AS TIP_AMOUNT
    ,t.[payment_id] AS PAYMENT_REF
    ,t.[location_id] AS LOCATION_ID
    ,t.[order_id] AS ORDER_ID
FROM [int_square001].[DL_ORDERS_TENDERS] t
JOIN [int_square001].[DL_ORDERS] o ON t.[order_id] = o.[id] AND t.[location_id] = o.[location_id]
WHERE o.[state] IN (''COMPLETED'', ''CANCELED'')
) AS source_query;
```
Staging table: `SQR_TENDER`. Tier 1.

**Line Item Tax** → `SQR_LINEITEM_TAX` from `DL_ORDERS_LINEITEMS_TAXES`:
```sql
IF OBJECT_ID(''stage.SQR_LINEITEM_TAX'', ''U'') IS NOT NULL
    DROP TABLE [stage].[SQR_LINEITEM_TAX];

SELECT * INTO [stage].[SQR_LINEITEM_TAX]
FROM (
SELECT
    CONCAT_WS(''-'', tx.[location_id], tx.[order_id], tx.[lineitem_uid], tx.[tax_uid], ''TAX'') AS SRC_KEY
    ,CONCAT_WS(''-'', tx.[location_id], tx.[order_id]) AS HEADER_ID
    ,''TAX'' AS LINEITEM_TYPE
    ,CAST(CAST(ISNULL(tx.[applied_money_amount],''0'') AS BIGINT) / 100.0 AS NVARCHAR(255)) AS GROSS_VALUE
    ,CAST(CAST(ISNULL(tx.[applied_money_amount],''0'') AS BIGINT) / 100.0 AS NVARCHAR(255)) AS TAX_VALUE
    ,CAST(CAST(ISNULL(tx.[applied_money_amount],''0'') AS BIGINT) / 100.0 AS NVARCHAR(255)) AS NET_VALUE
    ,''1'' AS QUANTITY
    ,NULL AS QUANTITY_INV
    ,o.[created_at] AS LINEITEM_TIMESTAMP
    ,CAST(CAST(COALESCE(o.[closed_at], o.[created_at]) AS DATE) AS NVARCHAR(255)) AS ITEM_DATE
    ,CAST(CAST(COALESCE(o.[closed_at], o.[created_at]) AS DATE) AS NVARCHAR(255)) AS ORDER_DATE
    ,''0'' AS VOID_FLAG
    ,tx.[tax_uid] AS LINE_ID
    ,NULL AS LINE_ORDER
    ,CAST(CAST(COALESCE(o.[closed_at], o.[created_at]) AS DATE) AS NVARCHAR(255)) AS TRADING_DATE
    ,tx.[catalog_object_id] AS TAX_SRC_KEY
    ,CONCAT_WS(''-'', tx.[location_id], tx.[order_id], tx.[lineitem_uid], ''PROD'') AS PARENT_LINEITEM_SRC_KEY
    ,tx.[location_id] AS LOCATION_ID
    ,tx.[order_id] AS ORDER_ID
FROM [int_square001].[DL_ORDERS_LINEITEMS_TAXES] tx
JOIN [int_square001].[DL_ORDERS] o ON tx.[order_id] = o.[id] AND tx.[location_id] = o.[location_id]
WHERE o.[state] IN (''COMPLETED'', ''CANCELED'')
) AS source_query;
```
Staging table: `SQR_LINEITEM_TAX`. Tier 1.

**Line Item Discount** → `SQR_LINEITEM_DISCOUNT` from `DL_ORDERS_LINEITEMS_DISCOUNTS`:
```sql
IF OBJECT_ID(''stage.SQR_LINEITEM_DISCOUNT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[SQR_LINEITEM_DISCOUNT];

SELECT * INTO [stage].[SQR_LINEITEM_DISCOUNT]
FROM (
SELECT
    CONCAT_WS(''-'', dx.[location_id], dx.[order_id], dx.[lineitem_uid], dx.[discount_uid], ''DISCOUNT'') AS SRC_KEY
    ,CONCAT_WS(''-'', dx.[location_id], dx.[order_id]) AS HEADER_ID
    ,''DISCOUNT'' AS LINEITEM_TYPE
    ,CAST(CAST(ISNULL(dx.[applied_money_amount],''0'') AS BIGINT) / -100.0 AS NVARCHAR(255)) AS GROSS_VALUE
    ,''0'' AS TAX_VALUE
    ,CAST(CAST(ISNULL(dx.[applied_money_amount],''0'') AS BIGINT) / -100.0 AS NVARCHAR(255)) AS NET_VALUE
    ,''1'' AS QUANTITY
    ,NULL AS QUANTITY_INV
    ,o.[created_at] AS LINEITEM_TIMESTAMP
    ,CAST(CAST(COALESCE(o.[closed_at], o.[created_at]) AS DATE) AS NVARCHAR(255)) AS ITEM_DATE
    ,CAST(CAST(COALESCE(o.[closed_at], o.[created_at]) AS DATE) AS NVARCHAR(255)) AS ORDER_DATE
    ,''0'' AS VOID_FLAG
    ,dx.[discount_uid] AS LINE_ID
    ,NULL AS LINE_ORDER
    ,CAST(CAST(COALESCE(o.[closed_at], o.[created_at]) AS DATE) AS NVARCHAR(255)) AS TRADING_DATE
    ,dx.[catalog_object_id] AS DISCOUNT_SRC_KEY
    ,CONCAT_WS(''-'', dx.[location_id], dx.[order_id], dx.[lineitem_uid], ''PROD'') AS PARENT_LINEITEM_SRC_KEY
    ,dx.[location_id] AS LOCATION_ID
    ,dx.[order_id] AS ORDER_ID
FROM [int_square001].[DL_ORDERS_LINEITEMS_DISCOUNTS] dx
JOIN [int_square001].[DL_ORDERS] o ON dx.[order_id] = o.[id] AND dx.[location_id] = o.[location_id]
WHERE o.[state] IN (''COMPLETED'', ''CANCELED'')
) AS source_query;
```
Staging table: `SQR_LINEITEM_DISCOUNT`. Tier 1. Note negative values for discounts.

**Line Item Modifier** → `SQR_LINEITEM_MODIFIER` from `DL_ORDERS_LINEITEMS_MODIFIERS`:
```sql
IF OBJECT_ID(''stage.SQR_LINEITEM_MODIFIER'', ''U'') IS NOT NULL
    DROP TABLE [stage].[SQR_LINEITEM_MODIFIER];

SELECT * INTO [stage].[SQR_LINEITEM_MODIFIER]
FROM (
SELECT
    CONCAT_WS(''-'', mx.[location_id], mx.[order_id], mx.[lineitem_uid], mx.[uid], ''MOD'') AS SRC_KEY
    ,CONCAT_WS(''-'', mx.[location_id], mx.[order_id]) AS HEADER_ID
    ,''MOD'' AS LINEITEM_TYPE
    ,CAST(CAST(ISNULL(mx.[total_price_money_amount],''0'') AS BIGINT) / 100.0 AS NVARCHAR(255)) AS GROSS_VALUE
    ,''0'' AS TAX_VALUE
    ,CAST(CAST(ISNULL(mx.[total_price_money_amount],''0'') AS BIGINT) / 100.0 AS NVARCHAR(255)) AS NET_VALUE
    ,COALESCE(mx.[quantity], ''1'') AS QUANTITY
    ,NULL AS QUANTITY_INV
    ,o.[created_at] AS LINEITEM_TIMESTAMP
    ,CAST(CAST(COALESCE(o.[closed_at], o.[created_at]) AS DATE) AS NVARCHAR(255)) AS ITEM_DATE
    ,CAST(CAST(COALESCE(o.[closed_at], o.[created_at]) AS DATE) AS NVARCHAR(255)) AS ORDER_DATE
    ,''0'' AS VOID_FLAG
    ,mx.[uid] AS LINE_ID
    ,NULL AS LINE_ORDER
    ,CAST(CAST(COALESCE(o.[closed_at], o.[created_at]) AS DATE) AS NVARCHAR(255)) AS TRADING_DATE
    ,mx.[catalog_object_id] AS MODIFIER_SRC_KEY
    ,CONCAT_WS(''-'', mx.[location_id], mx.[order_id], mx.[lineitem_uid], ''PROD'') AS PARENT_LINEITEM_SRC_KEY
    ,mx.[location_id] AS LOCATION_ID
    ,mx.[order_id] AS ORDER_ID
    ,mx.[lineitem_uid] AS LINEITEM_UID
FROM [int_square001].[DL_ORDERS_LINEITEMS_MODIFIERS] mx
JOIN [int_square001].[DL_ORDERS] o ON mx.[order_id] = o.[id] AND mx.[location_id] = o.[location_id]
WHERE o.[state] IN (''COMPLETED'', ''CANCELED'')
) AS source_query;
```
Staging table: `SQR_LINEITEM_MODIFIER`. Tier 1.

**Service Charge Line** → `SQR_LINEITEM_SVC` from `DL_ORDERS_SERVICECHARGES`:
```sql
IF OBJECT_ID(''stage.SQR_LINEITEM_SVC'', ''U'') IS NOT NULL
    DROP TABLE [stage].[SQR_LINEITEM_SVC];

SELECT * INTO [stage].[SQR_LINEITEM_SVC]
FROM (
SELECT
    CONCAT_WS(''-'', sc.[location_id], sc.[order_id], sc.[uid], ''SVC'') AS SRC_KEY
    ,CONCAT_WS(''-'', sc.[location_id], sc.[order_id]) AS HEADER_ID
    ,''SVC'' AS LINEITEM_TYPE
    ,CAST(CAST(ISNULL(sc.[total_money_amount],''0'') AS BIGINT) / 100.0 AS NVARCHAR(255)) AS GROSS_VALUE
    ,''0'' AS TAX_VALUE
    ,CAST(CAST(ISNULL(sc.[total_money_amount],''0'') AS BIGINT) / 100.0 AS NVARCHAR(255)) AS NET_VALUE
    ,''1'' AS QUANTITY
    ,NULL AS QUANTITY_INV
    ,o.[created_at] AS LINEITEM_TIMESTAMP
    ,CAST(CAST(COALESCE(o.[closed_at], o.[created_at]) AS DATE) AS NVARCHAR(255)) AS ITEM_DATE
    ,CAST(CAST(COALESCE(o.[closed_at], o.[created_at]) AS DATE) AS NVARCHAR(255)) AS ORDER_DATE
    ,''0'' AS VOID_FLAG
    ,sc.[uid] AS LINE_ID
    ,NULL AS LINE_ORDER
    ,CAST(CAST(COALESCE(o.[closed_at], o.[created_at]) AS DATE) AS NVARCHAR(255)) AS TRADING_DATE
    ,sc.[name] AS SVC_NAME
    ,sc.[location_id] AS LOCATION_ID
    ,sc.[order_id] AS ORDER_ID
FROM [int_square001].[DL_ORDERS_SERVICECHARGES] sc
JOIN [int_square001].[DL_ORDERS] o ON sc.[order_id] = o.[id] AND sc.[location_id] = o.[location_id]
WHERE o.[state] IN (''COMPLETED'', ''CANCELED'')
) AS source_query;
```
Staging table: `SQR_LINEITEM_SVC`. Tier 1.

- [ ] **Step 4: Commit**

```bash
git add ClaudeDevelopment/integrations/Square/03_Square001_Staging.sql
git commit -m "feat(square): add staging Tier 1 transactional steps (7)"
```

---

## Task 5: Staging Script — Tier 1 Inventory, Refund, CRM, Workforce Steps (7 steps)

**Files:**
- Modify: `ClaudeDevelopment/integrations/Square/03_Square001_Staging.sql`

- [ ] **Step 1: Write Inventory Item step**

`query_sql` for `SQR_INVITEM` from `DL_CATALOG_ITEMVARIATIONS`:
```sql
IF OBJECT_ID(''stage.SQR_INVITEM'', ''U'') IS NOT NULL
    DROP TABLE [stage].[SQR_INVITEM];

SELECT * INTO [stage].[SQR_INVITEM]
FROM (
SELECT
    v.[id] AS ITEM_SRC_KEY
    ,COALESCE(v.[item_variation_data_name], i.[item_data_name]) AS INVITEM_NAME
    ,v.[item_variation_data_item_id] AS PARENT_ID
    ,''BOTTOM'' AS LEVEL_NAME
    ,1 AS BOTTOM_LEVEL
    ,v.[item_variation_data_measurement_unit_id] AS UOM
    ,NULL AS ATTR_1
    ,NULL AS ATTR_2
    ,NULL AS ATTR_3
    ,NULL AS ATTR_4
    ,NULL AS ATTR_5
    ,NULL AS MICROSERVICE_ID
    ,v.[id] AS INVITEM_ID
    ,NULL AS UOM_COST
FROM (
    SELECT *, ROW_NUMBER() OVER(PARTITION BY [id] ORDER BY [LOADTS_UTC] DESC) AS RN
    FROM [int_square001].[DL_CATALOG_ITEMVARIATIONS]
    WHERE [item_variation_data_track_inventory] = ''true''
      AND ([is_deleted] = ''false'' OR [is_deleted] IS NULL)
) v
LEFT JOIN [int_square001].[DL_CATALOG_ITEMS] i ON v.[item_variation_data_item_id] = i.[id]
WHERE v.RN = 1
) AS source_query;
```
Staging table: `SQR_INVITEM`. Tier 1.
Columns: `["ITEM_SRC_KEY", "INVITEM_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "UOM", "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5", "MICROSERVICE_ID", "INVITEM_ID", "UOM_COST"]`

- [ ] **Step 2: Write Stock Event step with CASE-based event type mapping**

`query_sql` for `SQR_STOCKEVENT` from `DL_INVENTORY_CHANGES`:
```sql
IF OBJECT_ID(''stage.SQR_STOCKEVENT'', ''U'') IS NOT NULL
    DROP TABLE [stage].[SQR_STOCKEVENT];

SELECT * INTO [stage].[SQR_STOCKEVENT]
FROM (
SELECT
    CONCAT_WS(''-'', [location_id], [id]) AS SRC_KEY
    ,CASE
        WHEN [type] = ''PHYSICAL_COUNT''                                    THEN ''COUNT''
        WHEN [to_state] = ''IN_STOCK'' AND [from_state] = ''NONE''         THEN ''ORDER''
        WHEN [to_state] = ''SOLD''                                         THEN ''SALE''
        WHEN [to_state] = ''WASTE''                                        THEN ''WASTE''
        WHEN [to_state] = ''IN_TRANSIT_TO''                                THEN ''TRANSFER''
        WHEN [to_state] = ''IN_STOCK'' AND [from_state] = ''IN_TRANSIT_TO'' THEN ''TRANSFER''
        WHEN [to_state] = ''COMPOSED''                                     THEN ''PRODUCTION''
        WHEN [from_state] = ''COMPOSED'' AND [to_state] = ''IN_STOCK''     THEN ''PRODUCTION''
        WHEN [from_state] IN (''SOLD'',''RETURNED_BY_CUSTOMER'')
             AND [to_state] = ''IN_STOCK''                                 THEN ''ORDER''
        ELSE ''ORDER''
     END AS EVENT_TYPE
    ,[occurred_at] AS EVENT_TS
    ,NULL AS PACK_DESC
    ,NULL AS PACK_QUANTITY
    ,NULL AS UOM
    ,CAST(CAST([quantity] AS DECIMAL(18,4)) AS NVARCHAR(255)) AS UOM_QUANITY
    ,[reference_id] AS EXTERNAL_REF
    ,[catalog_object_id] AS INTERNAL_REF
    ,CASE
        WHEN [type] = ''PHYSICAL_COUNT''                                        THEN ''COUNT''
        WHEN [to_state] IN (''SOLD'',''WASTE'',''IN_TRANSIT_TO'',''COMPOSED'') THEN ''-''
        WHEN [to_state] = ''IN_STOCK''                                         THEN ''+''
        ELSE ''+''
     END AS EVENT_BEHAVIOUR
    ,[catalog_object_id] AS INVITEM_SRC_KEY
    ,[location_id] AS LOCATION_ID
FROM [int_square001].[DL_INVENTORY_CHANGES]
) AS source_query;
```
Staging table: `SQR_STOCKEVENT`. Tier 1.
Columns: `["SRC_KEY", "EVENT_TYPE", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY", "UOM", "UOM_QUANITY", "EXTERNAL_REF", "INTERNAL_REF", "EVENT_BEHAVIOUR", "INVITEM_SRC_KEY", "LOCATION_ID"]`

- [ ] **Step 3: Write Refund step**

`query_sql` for `SQR_REFUND` from `DL_REFUNDS`:
```sql
IF OBJECT_ID(''stage.SQR_REFUND'', ''U'') IS NOT NULL
    DROP TABLE [stage].[SQR_REFUND];

SELECT * INTO [stage].[SQR_REFUND]
FROM (
SELECT
    [id] AS SRC_KEY
    ,[created_at] AS REFUND_TIMESTAMP
    ,CAST(CAST(ISNULL([amount_money_amount],''0'') AS BIGINT) / 100.0 AS NVARCHAR(255)) AS REFUND_VALUE
    ,[id] AS REFUND_REF
    ,[reason] AS REFUND_INFO
    ,0 AS TAX_RECLAIM_FLAG
    ,CONCAT(''Payment: '', [payment_id], '' | Status: '', [status]) AS REFUND_DETAIL
    ,CONCAT_WS(''-'', [location_id], [order_id]) AS ORDER_HEADER_ID
    ,[payment_id] AS PAYMENT_REF
FROM [int_square001].[DL_REFUNDS]
) AS source_query;
```
Staging table: `SQR_REFUND`. Tier 1.
Columns: `["SRC_KEY", "REFUND_TIMESTAMP", "REFUND_VALUE", "REFUND_REF", "REFUND_INFO", "TAX_RECLAIM_FLAG", "REFUND_DETAIL", "ORDER_HEADER_ID", "PAYMENT_REF"]`

- [ ] **Step 4: Write Customer step**

`query_sql` for `SQR_CUSTOMER` from `DL_CUSTOMERS`:
```sql
IF OBJECT_ID(''stage.SQR_CUSTOMER'', ''U'') IS NOT NULL
    DROP TABLE [stage].[SQR_CUSTOMER];

SELECT * INTO [stage].[SQR_CUSTOMER]
FROM (
SELECT
    [id] AS ITEM_SRC_KEY
    ,[given_name] AS FORENAME
    ,[family_name] AS SURNAME
    ,NULL AS MIDDLE_NAMES
    ,NULL AS TITLE
    ,NULL AS GENDER
    ,[birthday] AS DOB
    ,[email_address] AS EMAIL
    ,[phone_number] AS PHONE
    ,CONCAT_WS('', '', [address_line_1], [address_line_2]) AS ADDRESS
    ,[postal_code] AS POSTCODE
    ,NULL AS REGION
    ,[country] AS COUNTRY
    ,NULL AS LAT
    ,NULL AS LONG_VAL
    ,[locality] AS TOWN
    ,NULL AS COUNTY
FROM (
    SELECT *, ROW_NUMBER() OVER(PARTITION BY [id] ORDER BY [LOADTS_UTC] DESC) AS RN
    FROM [int_square001].[DL_CUSTOMERS]
) sub WHERE RN = 1
) AS source_query;
```
Staging table: `SQR_CUSTOMER`. Tier 1.
Columns: `["ITEM_SRC_KEY", "FORENAME", "SURNAME", "MIDDLE_NAMES", "TITLE", "GENDER", "DOB", "EMAIL", "PHONE", "ADDRESS", "POSTCODE", "REGION", "COUNTRY", "LAT", "LONG_VAL", "TOWN", "COUNTY"]`

- [ ] **Step 5: Write Employee, Job, and Timecard steps**

**Employee** → `SQR_EMPLOYEE` from `DL_TEAM_MEMBERS`:
```sql
IF OBJECT_ID(''stage.SQR_EMPLOYEE'', ''U'') IS NOT NULL
    DROP TABLE [stage].[SQR_EMPLOYEE];

SELECT * INTO [stage].[SQR_EMPLOYEE]
FROM (
SELECT
    [id] AS ITEM_SRC_KEY
    ,[family_name] AS SURNAME
    ,[given_name] AS FIRST_NAME
    ,NULL AS MIDDLE_NAME
FROM (
    SELECT *, ROW_NUMBER() OVER(PARTITION BY [id] ORDER BY [LOADTS_UTC] DESC) AS RN
    FROM [int_square001].[DL_TEAM_MEMBERS]
    WHERE [status] = ''ACTIVE''
) sub WHERE RN = 1
) AS source_query;
```
Staging table: `SQR_EMPLOYEE`. Tier 1.

**Job** → `SQR_JOB` from `DL_SHIFTS`:
```sql
IF OBJECT_ID(''stage.SQR_JOB'', ''U'') IS NOT NULL
    DROP TABLE [stage].[SQR_JOB];

SELECT * INTO [stage].[SQR_JOB]
FROM (
SELECT DISTINCT
    [wage_title] AS ITEM_SRC_KEY
    ,[wage_title] AS JOB_NAME
    ,NULL AS JOB_CODE
FROM [int_square001].[DL_SHIFTS]
WHERE [wage_title] IS NOT NULL
) AS source_query;
```
Staging table: `SQR_JOB`. Tier 1.

**Timecard** → `SQR_TIMECARD` from `DL_SHIFTS`:
```sql
IF OBJECT_ID(''stage.SQR_TIMECARD'', ''U'') IS NOT NULL
    DROP TABLE [stage].[SQR_TIMECARD];

SELECT * INTO [stage].[SQR_TIMECARD]
FROM (
SELECT
    CONCAT_WS(''-'', [location_id], [id]) AS SRC_KEY
    ,CAST(CAST([start_at] AS DATE) AS NVARCHAR(255)) AS TRADING_DATE
    ,[start_at] AS CLOCK_IN_TS
    ,[end_at] AS CLOCK_OUT_TS
    ,CAST(DATEDIFF(MINUTE, CAST([start_at] AS DATETIME2), CAST([end_at] AS DATETIME2)) AS NVARCHAR(255)) AS MINS_WORKED
    ,NULL AS HOURS_ADJ
    ,NULL AS OVERTIME_MINS
    ,[team_member_id] AS EMPLOYEE_SRC_KEY
    ,[wage_title] AS JOB_SRC_KEY
    ,[location_id] AS LOCATION_ID
FROM [int_square001].[DL_SHIFTS]
WHERE [status] = ''CLOSED''
  AND [end_at] IS NOT NULL
) AS source_query;
```
Staging table: `SQR_TIMECARD`. Tier 1.

- [ ] **Step 6: Commit**

```bash
git add ClaudeDevelopment/integrations/Square/03_Square001_Staging.sql
git commit -m "feat(square): add staging Tier 1 inventory/refund/CRM/workforce steps (7)"
```

---

## Task 6: Staging Script — Tier 2 Link Steps (16 steps) + Tier 3 (1 step)

**Files:**
- Modify: `ClaudeDevelopment/integrations/Square/03_Square001_Staging.sql`

All Tier 2 steps have `depends_on_steps` referencing their Tier 1 sources. The query pattern is simpler — selecting key columns from Tier 1 staging tables.

- [ ] **Step 1: Write the 16 Tier 2 link staging steps**

Each step selects the hub key columns needed for a specific link entity mapping. All Tier 2 steps follow this pattern:

```sql
-- Step: Order to Location (Tier 2)
-- query_sql:
IF OBJECT_ID(''stage.SQR_CUSTORDER_LOCATION'', ''U'') IS NOT NULL
    DROP TABLE [stage].[SQR_CUSTORDER_LOCATION];

SELECT * INTO [stage].[SQR_CUSTORDER_LOCATION]
FROM (
SELECT DISTINCT
    HEADER_ID
    ,LOCATION_ID
FROM [stage].[SQR_CUSTORDER]
) AS source_query;
```
Tier 2. `depends_on_steps = N'Customer Order'`.

The remaining 15 Tier 2 steps follow the same pattern. Here is each step's SELECT body:

**Order to Channel** → `SQR_CHANNEL_CUSTORDER`:
```sql
SELECT DISTINCT HEADER_ID, CHANNEL_NAME
FROM [stage].[SQR_CUSTORDER]
WHERE CHANNEL_NAME IS NOT NULL
```
`depends_on_steps = N'Customer Order'`

**Order to Occasion** → `SQR_CUSTORDER_OCCASION`:
```sql
SELECT DISTINCT
    o.HEADER_ID
    ,COALESCE(f.[type], ''DINE_IN'') AS OCCASION_NAME
FROM [stage].[SQR_CUSTORDER] o
LEFT JOIN [int_square001].[DL_ORDERS_FULFILLMENTS] f
    ON o.HEADER_ID = CONCAT_WS(''-'', f.[location_id], f.[order_id])
```
`depends_on_steps = N'Customer Order'`

**Line Item to Order** → `SQR_CUSTORDER_LINEITEM`:
```sql
SELECT DISTINCT HEADER_ID, SRC_KEY
FROM [stage].[SQR_LINEITEM]
```
`depends_on_steps = N'Line Item'`

**Line Item to Product** → `SQR_LINEITEM_PRODUCT`:
```sql
SELECT DISTINCT SRC_KEY, PRODUCT_SRC_KEY
FROM [stage].[SQR_LINEITEM]
WHERE PRODUCT_SRC_KEY IS NOT NULL
```
`depends_on_steps = N'Line Item'`

**Line Item to Occasion** → `SQR_LINEITEM_OCCASION`:
```sql
SELECT DISTINCT
    li.SRC_KEY
    ,COALESCE(f.[type], ''DINE_IN'') AS OCCASION_NAME
FROM [stage].[SQR_LINEITEM] li
LEFT JOIN [int_square001].[DL_ORDERS_FULFILLMENTS] f
    ON li.ORDER_ID = f.[order_id] AND li.LOCATION_ID = f.[location_id]
```
`depends_on_steps = N'Line Item'`

**Tax to Line Item** → `SQR_LINEITEM_TAX_LNK`:
```sql
SELECT DISTINCT SRC_KEY, TAX_SRC_KEY
FROM [stage].[SQR_LINEITEM_TAX]
WHERE TAX_SRC_KEY IS NOT NULL
```
`depends_on_steps = N'Line Item Tax'`

**Discount to Line Item** → `SQR_DISCOUNT_LINEITEM`:
```sql
SELECT DISTINCT SRC_KEY, DISCOUNT_SRC_KEY
FROM [stage].[SQR_LINEITEM_DISCOUNT]
WHERE DISCOUNT_SRC_KEY IS NOT NULL
```
`depends_on_steps = N'Line Item Discount'`

**Modifier to Line Item** → `SQR_LINEITEM_MOD`:
```sql
SELECT DISTINCT SRC_KEY, MODIFIER_SRC_KEY
FROM [stage].[SQR_LINEITEM_MODIFIER]
WHERE MODIFIER_SRC_KEY IS NOT NULL
```
`depends_on_steps = N'Line Item Modifier'`

**Tender to Line Item** → `SQR_LINEITEM_TENDER`:
```sql
SELECT DISTINCT SRC_KEY, TENDER_TYPE
FROM [stage].[SQR_TENDER]
```
`depends_on_steps = N'Tender'`

**SvcCharge to Line Item** → `SQR_LINEITEM_SVC_LNK`:
```sql
SELECT DISTINCT SRC_KEY, SVC_NAME
FROM [stage].[SQR_LINEITEM_SVC]
WHERE SVC_NAME IS NOT NULL
```
`depends_on_steps = N'Service Charge Line'`

**InvItem to StockEvent** → `SQR_INVITEM_STOCKEVENT`:
```sql
SELECT DISTINCT INVITEM_SRC_KEY, SRC_KEY
FROM [stage].[SQR_STOCKEVENT]
WHERE INVITEM_SRC_KEY IS NOT NULL
```
`depends_on_steps = N'Stock Event'`

**Location to StockEvent** → `SQR_LOCATION_STOCKEVENT`:
```sql
SELECT DISTINCT LOCATION_ID, SRC_KEY
FROM [stage].[SQR_STOCKEVENT]
WHERE LOCATION_ID IS NOT NULL
```
`depends_on_steps = N'Stock Event'`

**Refund to Order** → `SQR_CUSTORDER_REFUND`:
```sql
SELECT DISTINCT ORDER_HEADER_ID, SRC_KEY
FROM [stage].[SQR_REFUND]
WHERE ORDER_HEADER_ID IS NOT NULL
```
`depends_on_steps = N'Refund'`

**Employee Job Timecard** → `SQR_EMP_JOB_TIMECARD`:
```sql
SELECT DISTINCT EMPLOYEE_SRC_KEY, JOB_SRC_KEY, SRC_KEY
FROM [stage].[SQR_TIMECARD]
WHERE EMPLOYEE_SRC_KEY IS NOT NULL AND JOB_SRC_KEY IS NOT NULL
```
`depends_on_steps = N'Timecard'`

**Order to Employee** → `SQR_CUSTORDER_EMPLOYEE`:
```sql
SELECT DISTINCT
    o.HEADER_ID
    ,s.[team_member_id] AS EMPLOYEE_SRC_KEY
FROM [stage].[SQR_CUSTORDER] o
JOIN [int_square001].[DL_SHIFTS] s
    ON o.LOCATION_ID = s.[location_id]
    AND CAST(o.ORDER_DATE AS DATETIME2) BETWEEN CAST(s.[start_at] AS DATETIME2) AND CAST(s.[end_at] AS DATETIME2)
WHERE s.[status] = ''CLOSED'' AND s.[end_at] IS NOT NULL
```
`depends_on_steps = N'Customer Order'`

- [ ] **Step 2: Write the Tier 3 self-referencing link step**

**Modifier to Parent Line Item** → `SQR_LINEITEM_LINEITEM` (Tier 3):
```sql
IF OBJECT_ID(''stage.SQR_LINEITEM_LINEITEM'', ''U'') IS NOT NULL
    DROP TABLE [stage].[SQR_LINEITEM_LINEITEM];

SELECT * INTO [stage].[SQR_LINEITEM_LINEITEM]
FROM (
SELECT DISTINCT
    m.SRC_KEY AS CHILD_SRC_KEY
    ,m.PARENT_LINEITEM_SRC_KEY AS PARENT_SRC_KEY
    ,m.LINEITEM_TYPE AS LABEL
    ,m.GROSS_VALUE AS VALUE
    ,NULL AS INFO
FROM [stage].[SQR_LINEITEM_MODIFIER] m
WHERE m.PARENT_LINEITEM_SRC_KEY IS NOT NULL
) AS source_query;
```
Tier 3. `depends_on_steps = N'Line Item Modifier'`.

- [ ] **Step 3: Commit**

```bash
git add ClaudeDevelopment/integrations/Square/03_Square001_Staging.sql
git commit -m "feat(square): add staging Tier 2 link steps (16) and Tier 3 self-ref (1)"
```

---

## Task 7: Mapping Script — Hub Mappings (26)

**Files:**
- Create: `ClaudeDevelopment/integrations/Square/04_Square001_Mapping.sql`

Every EntityMappings upsert follows the NCRAloha pattern: IF EXISTS UPDATE ELSE INSERT. The `id` column in the INSERT uses hex-only GUIDs. Prefer omitting `id` and letting `DEFAULT NEWID()` handle it — but the IF EXISTS pattern needs a match key, which is `entity_name`.

**Important:** For LINEITEM hub, there are 6 separate mappings from different source tables. Each needs a unique `entity_name` suffix: `LINEITEM`, `LINEITEM_TENDER`, `LINEITEM_TAX`, `LINEITEM_DISCOUNT`, `LINEITEM_MOD`, `LINEITEM_SVC`.

Wait — EntityMappings uses `entity_name` as the key, and `UploadEntityMappings` matches it to `DataVaultEntities.ENTITY_NAME`. Multiple mappings to the same entity from different source tables need different `entity_name` values that still resolve to the same DV entity. Looking at the NCRAloha pattern: NCRAloha only has one LINEITEM mapping because it UNIONs everything into one staging table.

For Square's separate-source-table approach, each source table mapping needs `split_by_source = 1` on the entity, OR we must use the existing pattern of one mapping per entity name. The simplest approach: **create a Tier 1.5 step that UNIONs all LINEITEM-typed staging tables into a single `SQR_LINEITEM_ALL` table**, then map from that.

**Revised approach:** Add one additional staging step `SQR_LINEITEM_ALL` that UNIONs `SQR_LINEITEM` + `SQR_TENDER` + `SQR_LINEITEM_TAX` + `SQR_LINEITEM_DISCOUNT` + `SQR_LINEITEM_MODIFIER` + `SQR_LINEITEM_SVC` with a consistent column schema. This is a Tier 2 step (depends on all 6 Tier 1 transactional steps). Then the single LINEITEM entity mapping reads from `SQR_LINEITEM_ALL`.

- [ ] **Step 1: Add the LINEITEM consolidation staging step to 03_Square001_Staging.sql**

Add this Tier 2 step to the staging script:

**Line Item Consolidation** → `SQR_LINEITEM_ALL` (Tier 2):
```sql
IF OBJECT_ID(''stage.SQR_LINEITEM_ALL'', ''U'') IS NOT NULL
    DROP TABLE [stage].[SQR_LINEITEM_ALL];

SELECT * INTO [stage].[SQR_LINEITEM_ALL]
FROM (
    SELECT SRC_KEY, HEADER_ID, LINEITEM_TYPE, GROSS_VALUE, TAX_VALUE, NET_VALUE,
           QUANTITY, QUANTITY_INV, LINEITEM_TIMESTAMP, ITEM_DATE, ORDER_DATE,
           VOID_FLAG, LINE_ID, LINE_ORDER, TRADING_DATE
    FROM [stage].[SQR_LINEITEM]
    UNION ALL
    SELECT SRC_KEY, HEADER_ID, LINEITEM_TYPE, GROSS_VALUE, TAX_VALUE, NET_VALUE,
           QUANTITY, QUANTITY_INV, LINEITEM_TIMESTAMP, ITEM_DATE, ORDER_DATE,
           VOID_FLAG, LINE_ID, LINE_ORDER, TRADING_DATE
    FROM [stage].[SQR_TENDER]
    UNION ALL
    SELECT SRC_KEY, HEADER_ID, LINEITEM_TYPE, GROSS_VALUE, TAX_VALUE, NET_VALUE,
           QUANTITY, QUANTITY_INV, LINEITEM_TIMESTAMP, ITEM_DATE, ORDER_DATE,
           VOID_FLAG, LINE_ID, LINE_ORDER, TRADING_DATE
    FROM [stage].[SQR_LINEITEM_TAX]
    UNION ALL
    SELECT SRC_KEY, HEADER_ID, LINEITEM_TYPE, GROSS_VALUE, TAX_VALUE, NET_VALUE,
           QUANTITY, QUANTITY_INV, LINEITEM_TIMESTAMP, ITEM_DATE, ORDER_DATE,
           VOID_FLAG, LINE_ID, LINE_ORDER, TRADING_DATE
    FROM [stage].[SQR_LINEITEM_DISCOUNT]
    UNION ALL
    SELECT SRC_KEY, HEADER_ID, LINEITEM_TYPE, GROSS_VALUE, TAX_VALUE, NET_VALUE,
           QUANTITY, QUANTITY_INV, LINEITEM_TIMESTAMP, ITEM_DATE, ORDER_DATE,
           VOID_FLAG, LINE_ID, LINE_ORDER, TRADING_DATE
    FROM [stage].[SQR_LINEITEM_MODIFIER]
    UNION ALL
    SELECT SRC_KEY, HEADER_ID, LINEITEM_TYPE, GROSS_VALUE, TAX_VALUE, NET_VALUE,
           QUANTITY, QUANTITY_INV, LINEITEM_TIMESTAMP, ITEM_DATE, ORDER_DATE,
           VOID_FLAG, LINE_ID, LINE_ORDER, TRADING_DATE
    FROM [stage].[SQR_LINEITEM_SVC]
) AS source_query;
```
Tier 2. `depends_on_steps = N'Line Item,Tender,Line Item Tax,Line Item Discount,Line Item Modifier,Service Charge Line'`

This brings the **total staging steps to 40** (22 Tier 1 + 17 Tier 2 + 1 Tier 3).

- [ ] **Step 2: Write the mapping script with all 26 hub mappings**

```sql
-- Square001 Entity Mappings
-- Schema: int_square001
-- Total Mappings: 45 (26 hub + 19 link)
```

Each hub mapping follows this pattern (showing LOCATION as the first example):

```sql
-- Entity: LOCATION (Hub)
IF EXISTS (SELECT 1 FROM core.int_square001.EntityMappings WHERE entity_name = 'LOCATION')
BEGIN
    UPDATE core.int_square001.EntityMappings
    SET source_table = 'SQR_LOCATION',
        source_columns = '[{"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "LOCATION_NAME", "hash": 0}, {"name": "LOCATION_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "MICROSERVICE_NAME", "hash": 0}, {"name": "MICROSERVICE_ID", "hash": 0}]',
        entity_columns = '["HUB_ID", "LOCATION_NAME", "LOCATION_ID", "LEVEL_NAME", "PARENT_ID", "BOTTOM_LEVEL", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
        type2_columns = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column = NULL,
        track_deletions = 0,
        updated_at = GETDATE()
    WHERE entity_name = 'LOCATION';
END
ELSE
BEGIN
    INSERT INTO core.int_square001.EntityMappings
    (entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('LOCATION', 'SQR_LOCATION',
            '[{"name": "ITEM_SRC_KEY", "hash": 1}, {"name": "LOCATION_NAME", "hash": 0}, {"name": "LOCATION_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "MICROSERVICE_NAME", "hash": 0}, {"name": "MICROSERVICE_ID", "hash": 0}]',
            '["HUB_ID", "LOCATION_NAME", "LOCATION_ID", "LEVEL_NAME", "PARENT_ID", "BOTTOM_LEVEL", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
END
GO
```

**All 26 hub mapping definitions** (entity_name → source_table → source_columns JSON → entity_columns JSON):

| entity_name | source_table | source_columns (hash:1 = business key, hash:0 = attribute) | entity_columns |
|---|---|---|---|
| LOCATION | SQR_LOCATION | ITEM_SRC_KEY(1), LOCATION_NAME(0), LOCATION_ID(0), LEVEL_NAME(0), PARENT_ID(0), BOTTOM_LEVEL(0), MICROSERVICE_NAME(0), MICROSERVICE_ID(0) | HUB_ID, LOCATION_NAME, LOCATION_ID, LEVEL_NAME, PARENT_ID, BOTTOM_LEVEL, MICROSERVICE_NAME, MICROSERVICE_ID |
| PRODUCT | SQR_PRODUCT | ITEM_SRC_KEY(1), PRODUCT_NAME(0), PRODUCT_ID(0), LEVEL_NAME(0), PARENT_ID(0), BOTTOM_LEVEL(0), MICROSERVICE_NAME(0), MICROSERVICE_ID(0) | HUB_ID, PRODUCT_NAME, PRODUCT_ID, LEVEL_NAME, PARENT_ID, BOTTOM_LEVEL, MICROSERVICE_NAME, MICROSERVICE_ID |
| CHANNEL | SQR_CHANNEL | ITEM_SRC_KEY(1), CHANNEL_NAME(0), CHANNEL_ID(0), LEVEL_NAME(0), BOTTOM_LEVEL(0) | HUB_ID, CHANNEL_NAME, CHANNEL_ID, LEVEL_NAME, BOTTOM_LEVEL |
| OCCASION | SQR_OCCASION | ITEM_SRC_KEY(1), OCCASION_NAME(0), OCCASSION_ID(0), LEVEL_NAME(0), PARENT_ID(0), BOTTOM_LEVEL(0) | HUB_ID, OCCASION_NAME, OCCASSION_ID, LEVEL_NAME, PARENT_ID, BOTTOM_LEVEL |
| TAX | SQR_TAX | ITEM_SRC_KEY(1), TAX_NAME(0), TAX_ID(0), TAX_MULTIPLIER(0), LEVEL_NAME(0), PARENT_ID(0) | HUB_ID, TAX_NAME, TAX_ID, TAX_MULTIPLIER, LEVEL_NAME, PARENT_ID |
| DISCOUNT | SQR_DISCOUNT | ITEM_SRC_KEY(1), DISCOUNT_NAME(0), DISCOUNT_ID(0), VALUE_TYPE(0), VALUE(0), IS_WASTE(0), LEVEL_NAME(0), PARENT_ID(0) | HUB_ID, DISCOUNT_NAME, DISCOUNT_ID, VALUE_TYPE, VALUE, IS_WASTE, LEVEL_NAME, PARENT_ID |
| MOD | SQR_MODIFIER | ITEM_SRC_KEY(1), MOD_NAME(0), MOD_ID(0), LEVEL_NAME(0), PARENT_ID(0), BOTTOM_LEVEL(0), MICROSERVICE_NAME(0), MICROSERVICE_ID(0) | HUB_ID, MOD_NAME, MOD_ID, LEVEL_NAME, PARENT_ID, BOTTOM_LEVEL, MICROSERVICE_NAME, MICROSERVICE_ID |
| SVCCHARGE | SQR_SERVICECHARGE | ITEM_SRC_KEY(1), SVCCHARGE_NAME(0), SVC_ID(0), LEVEL_NAME(0), PARENT_ID(0) | HUB_ID, SVCCHARGE_NAME, SVC_ID, LEVEL_NAME, PARENT_ID |
| TENDER | SQR_TENDER | TENDER_TYPE(1), TENDER_NAME(0), TENDER_TYPE(0), LEVEL_NAME=BOTTOM(0), PARENT_ID=NULL(0) | HUB_ID, TENDER_NAME, TENDER_ID, LEVEL_NAME, PARENT_ID |
| CUSTORDER | SQR_CUSTORDER | HEADER_ID(1), GRAND_TOTAL(0), DISCOUNT_GROSS(0), GROSS_SALES(0), NET_SALES(0), TAX_TOTAL(0), GROSS_SALES(0), GROSS_SALES(0), SVC_CHARGE_TOTAL(0), ITEM_COUNT(0), GUEST_COUNT(0), NULL(0), OPEN_TIME(0), CLOSE_TIME(0), ORDER_DATE(0), ORDER_INFO(0), EXTERNAL_REFERENCE(0), TRADING_DATE(0), ORDER_STATUS(0), PAYMENT_STATUS(0), TENDERED_SALES(0) | HUB_ID, GRAND_TOTAL_SRC, DISCOUNT_GROSS, NET_SALES_SRC, NET_SALES, TAX_TOTAL, GROSS_SALES_SRC, GROSS_SALES, SVC_CHARGE_TOTAL, ITEM_COUNT, GUEST_COUNT, ORDER_COUNT, OPEN_TIME, CLOSE_TIME, ORDER_DATE, ORDER_INFO, EXTERNAL_REFERENCE, TRADING_DATE, ORDER_STATUS, PAYMENT_STATUS, TENDERED_SALES |
| LINEITEM | SQR_LINEITEM_ALL | SRC_KEY(1), HEADER_ID(0), LINEITEM_TYPE(0), GROSS_VALUE(0), TAX_VALUE(0), NET_VALUE(0), QUANTITY(0), QUANTITY_INV(0), LINEITEM_TIMESTAMP(0), ITEM_DATE(0), ORDER_DATE(0), VOID_FLAG(0), LINE_ID(0), LINE_ORDER(0), TRADING_DATE(0) | HUB_ID, HEADER_ID, LINEITEM_TYPE, GROSS_VALUE, TAX_VALUE, NET_VALUE, QUANTITY, QUANTITY_INV, LINEITEM_TIMESTAMP, ITEM_DATE, ORDER_DATE, VOID_FLAG, LINE_ID, LINE_ORDER, TRADING_DATE |
| INVITEM | SQR_INVITEM | ITEM_SRC_KEY(1), INVITEM_NAME(0), PARENT_ID(0), LEVEL_NAME(0), BOTTOM_LEVEL(0), UOM(0), ATTR_1(0), ATTR_2(0), ATTR_3(0), ATTR_4(0), ATTR_5(0), MICROSERVICE_ID(0), INVITEM_ID(0) | HUB_ID, INVITEM_NAME, PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL, UOM, ATTR_1, ATTR_2, ATTR_3, ATTR_4, ATTR_5, MICROSERVICE_ID, INVITEM_ID |
| STOCKEVENT | SQR_STOCKEVENT | SRC_KEY(1), EVENT_TYPE(0), EVENT_TS(0), PACK_DESC(0), PACK_QUANTITY(0), UOM(0), UOM_QUANITY(0), EXTERNAL_REF(0), INTERNAL_REF(0), EVENT_BEHAVIOUR(0) | HUB_ID, EVENT_TYPE, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, UOM_QUANITY, EXTERNAL_REF, INTERNAL_REF, EVENT_BEHAVIOUR |
| REFUND | SQR_REFUND | SRC_KEY(1), REFUND_TIMESTAMP(0), REFUND_VALUE(0), REFUND_REF(0), REFUND_INFO(0), TAX_RECLAIM_FLAG(0), REFUND_DETAIL(0) | HUB_ID, REFUND_TIMESTAMP, REFUND_VALUE, REFUND_REF, REFUND_INFO, TAX_RECLAIM_FLAG, REFUND_DETAIL |
| INDIVIDUAL | SQR_CUSTOMER | ITEM_SRC_KEY(1), FORENAME(0), SURNAME(0), MIDDLE_NAMES(0), TITLE(0), GENDER(0), DOB(0) | HUB_ID, FORENAME, SURNAME, MIDDLE_NAMES, TITLE, GENDER, DOB |
| ADDRESS | SQR_CUSTOMER | ITEM_SRC_KEY(1), ADDRESS(0), POSTCODE(0), REGION(0), COUNTRY(0), LAT(0), LONG_VAL(0), TOWN(0), COUNTY(0) | HUB_ID, ADDRESS, POSTCODE, REGION, COUNTRY, LAT, LONG, TOWN, COUNTY |
| CONTACT | SQR_CUSTOMER | EMAIL(1), EMAIL(0), CONTACT_TYPE=EMAIL(0), OPT_OUT=0(0), BOUNCE=0(0), BLACKLIST=0(0), EMAIL(0) | HUB_ID, CONTACT, CONTACT_TYPE, OPT_OUT, BOUNCE, BLACKLIST, ADJUSTED_CONTACT |
| EMPLOYEE | SQR_EMPLOYEE | ITEM_SRC_KEY(1), SURNAME(0), FIRST_NAME(0), MIDDLE_NAME(0) | HUB_ID, SURNAME, FIRST_NAME, MIDDLE_NAME |
| JOB | SQR_JOB | ITEM_SRC_KEY(1), JOB_NAME(0), JOB_CODE(0) | HUB_ID, JOB_NAME, JOB_CODE |
| TIMECARD | SQR_TIMECARD | SRC_KEY(1), TRADING_DATE(0), CLOCK_IN_TS(0), CLOCK_OUT_TS(0), MINS_WORKED(0), HOURS_ADJ(0), OVERTIME_MINS(0) | HUB_ID, TRADING_DATE, CLOCK_IN_TS, CLOCK_OUT_TS, MINS_WORKED, HOURS_ADJ, OVERTIME_MINS |

**Note on CONTACT:** The CONTACT entity needs both email and phone mapped. This requires either two staging rows per customer (UNION in a staging step) or two entity mappings. Since `entity_name` must be unique, the simplest approach is to modify the `SQR_CUSTOMER` staging step to UNION email and phone into separate rows with a `CONTACT_TYPE` discriminator, then use one CONTACT mapping. The staging step modification adds:

```sql
-- Add to SQR_CUSTOMER staging or create a separate SQR_CONTACT step:
SELECT ITEM_SRC_KEY + ''-EMAIL'' AS CONTACT_SRC_KEY, EMAIL AS CONTACT_VAL, ''EMAIL'' AS CONTACT_TYPE FROM ...
UNION ALL
SELECT ITEM_SRC_KEY + ''-PHONE'' AS CONTACT_SRC_KEY, PHONE AS CONTACT_VAL, ''PHONE'' AS CONTACT_TYPE FROM ...
WHERE PHONE IS NOT NULL
```

The implementor should create a separate Tier 1 step `SQR_CONTACT` that produces these UNION rows, and map CONTACT from `SQR_CONTACT` instead of `SQR_CUSTOMER`.

- [ ] **Step 3: Commit**

```bash
git add ClaudeDevelopment/integrations/Square/03_Square001_Staging.sql
git add ClaudeDevelopment/integrations/Square/04_Square001_Mapping.sql
git commit -m "feat(square): add LINEITEM consolidation step + hub entity mappings (26)"
```

---

## Task 8: Mapping Script — Link Mappings (19)

**Files:**
- Modify: `ClaudeDevelopment/integrations/Square/04_Square001_Mapping.sql`

- [ ] **Step 1: Write all 19 link mappings**

Link mappings only contain `hash: 1` columns (hub references). Pattern (showing CUSTORDER_LOCATION):

```sql
-- Entity: CUSTORDER_LOCATION (Link)
IF EXISTS (SELECT 1 FROM core.int_square001.EntityMappings WHERE entity_name = 'CUSTORDER_LOCATION')
BEGIN
    UPDATE core.int_square001.EntityMappings
    SET source_table = 'SQR_CUSTORDER_LOCATION',
        source_columns = '[{"name": "HEADER_ID", "hash": 1}, {"name": "LOCATION_ID", "hash": 1}]',
        entity_columns = '["CUSTORDER_HUB_ID", "LOCATION_HUB_ID"]',
        type2_columns = NULL, cdc_exclude_columns = NULL, date_filter_column = NULL,
        track_deletions = 0, updated_at = GETDATE()
    WHERE entity_name = 'CUSTORDER_LOCATION';
END
ELSE
BEGIN
    INSERT INTO core.int_square001.EntityMappings
    (entity_name, source_table, source_columns, entity_columns,
     type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
     created_at, updated_at, is_active)
    VALUES ('CUSTORDER_LOCATION', 'SQR_CUSTORDER_LOCATION',
            '[{"name": "HEADER_ID", "hash": 1}, {"name": "LOCATION_ID", "hash": 1}]',
            '["CUSTORDER_HUB_ID", "LOCATION_HUB_ID"]',
            NULL, NULL, NULL, 0, GETDATE(), GETDATE(), 1);
END
GO
```

**All 19 link mapping definitions:**

| entity_name | source_table | source_columns (all hash:1) | entity_columns | SAT_LNK attrs | type2_columns |
|---|---|---|---|---|---|
| CUSTORDER_LOCATION | SQR_CUSTORDER_LOCATION | HEADER_ID, LOCATION_ID | CUSTORDER_HUB_ID, LOCATION_HUB_ID | — | — |
| CUSTORDER_OCCASION | SQR_CUSTORDER_OCCASION | HEADER_ID, OCCASION_NAME | CUSTORDER_HUB_ID, OCCASION_HUB_ID | — | — |
| CHANNEL_CUSTORDER | SQR_CHANNEL_CUSTORDER | HEADER_ID, CHANNEL_NAME | CUSTORDER_HUB_ID, CHANNEL_HUB_ID | — | — |
| CUSTORDER_LINEITEM | SQR_CUSTORDER_LINEITEM | HEADER_ID, SRC_KEY | CUSTORDER_HUB_ID, LINEITEM_HUB_ID | — | — |
| LINEITEM_PRODUCT | SQR_LINEITEM_PRODUCT | SRC_KEY, PRODUCT_SRC_KEY | LINEITEM_HUB_ID, PRODUCT_HUB_ID | — | — |
| LINEITEM_OCCASION | SQR_LINEITEM_OCCASION | SRC_KEY, OCCASION_NAME | LINEITEM_HUB_ID, OCCASION_HUB_ID | — | — |
| LINEITEM_TAX | SQR_LINEITEM_TAX_LNK | SRC_KEY, TAX_SRC_KEY | LINEITEM_HUB_ID, TAX_HUB_ID | — | — |
| DISCOUNT_LINEITEM | SQR_DISCOUNT_LINEITEM | SRC_KEY, DISCOUNT_SRC_KEY | LINEITEM_HUB_ID, DISCOUNT_HUB_ID | — | — |
| LINEITEM_MOD | SQR_LINEITEM_MOD | SRC_KEY, MODIFIER_SRC_KEY | LINEITEM_HUB_ID, MOD_HUB_ID | — | — |
| LINEITEM_TENDER | SQR_LINEITEM_TENDER | SRC_KEY, TENDER_TYPE | LINEITEM_HUB_ID, TENDER_HUB_ID | — | — |
| LINEITEM_SVCCHARGE | SQR_LINEITEM_SVC_LNK | SRC_KEY, SVC_NAME | LINEITEM_HUB_ID, SVCCHARGE_HUB_ID | — | — |
| LINEITEM_LINEITEM | SQR_LINEITEM_LINEITEM | PARENT_SRC_KEY, CHILD_SRC_KEY | LINEITEM_HUB_ID, LINEITEM_HUB_ID | LABEL(0), VALUE(0), INFO(0) | — |
| INVITEM_STOCKEVENT | SQR_INVITEM_STOCKEVENT | INVITEM_SRC_KEY, SRC_KEY | INVITEM_HUB_ID, STOCKEVENT_HUB_ID | — | — |
| LOCATION_STOCKEVENT | SQR_LOCATION_STOCKEVENT | LOCATION_ID, SRC_KEY | LOCATION_HUB_ID, STOCKEVENT_HUB_ID | — | — |
| CUSTORDER_REFUND | SQR_CUSTORDER_REFUND | ORDER_HEADER_ID, SRC_KEY | CUSTORDER_HUB_ID, REFUND_HUB_ID | — | — |
| ADDRESS_INDIVIDUAL | SQR_CUSTOMER | ITEM_SRC_KEY, ITEM_SRC_KEY | ADDRESS_HUB_ID, INDIVIDUAL_HUB_ID | — | — |
| CONTACT_INDIVIDUAL | SQR_CONTACT | CONTACT_SRC_KEY, ITEM_SRC_KEY | CONTACT_HUB_ID, INDIVIDUAL_HUB_ID | — | — |
| EMPLOYEE_JOB_TIMECARD | SQR_EMP_JOB_TIMECARD | EMPLOYEE_SRC_KEY, JOB_SRC_KEY, SRC_KEY | EMPLOYEE_HUB_ID, JOB_HUB_ID, TIMECARD_HUB_ID | — | — |
| CUSTORDER_EMPLOYEE | SQR_CUSTORDER_EMPLOYEE | HEADER_ID, EMPLOYEE_SRC_KEY | CUSTORDER_HUB_ID, EMPLOYEE_HUB_ID | — | — |

**LINEITEM_LINEITEM special case:** This link has SAT_LNK attributes. The source_columns include hash:0 entries after the two hash:1 hub keys:
```json
source_columns = '[{"name": "PARENT_SRC_KEY", "hash": 1}, {"name": "CHILD_SRC_KEY", "hash": 1}, {"name": "LABEL", "hash": 0}, {"name": "VALUE", "hash": 0}, {"name": "INFO", "hash": 0}]'
entity_columns = '["LINEITEM_HUB_ID", "LINEITEM_HUB_ID", "LABEL", "VALUE", "INFO"]'
```

- [ ] **Step 2: Commit**

```bash
git add ClaudeDevelopment/integrations/Square/04_Square001_Mapping.sql
git commit -m "feat(square): add link entity mappings (19)"
```

---

## Task 9: Final Script + Documentation

**Files:**
- Create: `ClaudeDevelopment/integrations/Square/05_Square001_Final.sql`
- Modify: `ClaudeDevelopment/QUERY_STATUS.md`

- [ ] **Step 1: Write the Final script**

```sql
USE [core]
GO

DECLARE @return_value int

EXEC @return_value = [core].[UploadEntityMappings]
        @intSchema = N'int_square001'

SELECT 'Return Value' = @return_value

GO
```

- [ ] **Step 2: Create DEPLOY.txt**

Create `ClaudeDevelopment/integrations/Square/DEPLOY.txt`:

```
Square001 Integration — Deployment Order
=========================================

Prerequisites:
- Core database must exist with AddIntegration and sp_CreateIntegrationTables procedures

Deployment Steps:
1. Run 01_Square001_INIT.sql against core database
2. Run: EXEC [core].[sp_CreateIntegrationTables] @DatabaseName = 'core', @SchemaName = 'int_square001'
3. Run 02_Square001_DDL.sql against core database
4. Run 03_Square001_Staging.sql against core database
5. Run 04_Square001_Mapping.sql against core database
6. Run 05_Square001_Final.sql against core database
7. Run sp_DeployObjects to deploy any new procedures (if needed)

Per-Organisation Activation:
8. EXEC [core].[MapOrganisationToIntegration] @OrganisationID = ?, @IntegrationID = ?
   (This triggers schema provisioning and DL table creation in the org database)

Notes:
- All scripts are idempotent and safe to re-run
- Scripts must be run in order (01 → 05)
- Step 2 (sp_CreateIntegrationTables) is a manual step between 01 and 02
- The integration schema int_square001 must exist before DDL/Staging/Mapping scripts run
```

- [ ] **Step 3: Update QUERY_STATUS.md**

Add entries for all 5 scripts + DEPLOY.txt to the Square integration section.

- [ ] **Step 4: Commit**

```bash
git add ClaudeDevelopment/integrations/Square/05_Square001_Final.sql
git add ClaudeDevelopment/integrations/Square/DEPLOY.txt
git add ClaudeDevelopment/QUERY_STATUS.md
git commit -m "feat(square): add Final script, deploy guide, and status tracking"
```

---

## Summary

| Task | Files | Steps | What it produces |
|---|---|---|---|
| 1 | 01_INIT.sql | 2 | Integration registration |
| 2 | 02_DDL.sql | 3 | 22 DL table definitions |
| 3 | 03_Staging.sql (partial) | 4 | 8 Tier 1 dimension staging steps |
| 4 | 03_Staging.sql (partial) | 4 | 7 Tier 1 transactional staging steps |
| 5 | 03_Staging.sql (partial) | 6 | 7 Tier 1 inventory/refund/CRM/workforce steps |
| 6 | 03_Staging.sql (partial) | 3 | 17 Tier 2 link steps + 1 Tier 3 self-ref |
| 7 | 03_Staging.sql + 04_Mapping.sql | 3 | LINEITEM consolidation step + 26 hub mappings |
| 8 | 04_Mapping.sql | 2 | 19 link mappings |
| 9 | 05_Final.sql + DEPLOY.txt + QUERY_STATUS.md | 4 | Final script + deploy guide + status tracking |

**Revised totals after adding LINEITEM consolidation + CONTACT staging steps:**
- DL tables: 22
- Staging steps: 41 (22 Tier 1 + 18 Tier 2 + 1 Tier 3)
- Entity mappings: 45 (26 hub + 19 link)
- Script files: 5 + DEPLOY.txt
