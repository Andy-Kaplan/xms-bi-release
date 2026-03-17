# XMS BI: Presentation Layer and Visualisation

## Document scope

This document covers every artefact in the XMS BI platform that sits between the raw Data Vault and the front-end dashboard. It describes:

- How presentation tables are structured and deployed (`6_DeployPresentationTables.sql`, `8_PresentationTables.sql`)
- How the 22 PresentationControl build steps populate those tables from the Data Vault (`8_PresentationControl.sql`)
- The complete catalogue of 109 visualisation queries served to the front end (`8_VisualisationQueries.sql`)
- The 16 card-type stored procedures and supporting infrastructure (`8_Deployment_Objects_Records.sql`)
- Dynamic suggestion / filter tables (`7_Dynamic Suggestion Tables.sql`)

---

## 1. Deployment procedure: `DeployPresentationTables`

**Source file:** `6_DeployPresentationTables.sql` (255 lines)

### Signature

```sql
CREATE OR ALTER PROCEDURE [core].[DeployPresentationTables]
    @DatabaseName   NVARCHAR(128),
    @DryRun         BIT = 0,
    @ContinueOnError BIT = 1,
    @LogResults     BIT = 1
```

### Behaviour

`DeployPresentationTables` is the deployment entry point for all presentation schema objects. It performs the following steps at runtime:

1. **Validates** that `@DatabaseName` is non-empty and that the target database exists in `sys.databases`.
2. Opens a **cursor** over `core.PresentationTables` filtered to `status = 'Live'` and `ddl_script IS NOT NULL`, ordered by `schema_name`, `table_name`.
3. For each row it builds dynamic SQL that:
   - Switches to the target database (`USE [@DatabaseName]`)
   - Creates the target schema if it does not yet exist (`IF NOT EXISTS … CREATE SCHEMA`)
   - **Drops** any existing table of the same name
   - Executes the stored `ddl_script`
4. In **dry-run mode** (`@DryRun = 1`) the SQL is constructed and printed but `sp_executesql` is never called.
5. Success and error outcomes are logged to a temporary table `#ProcessingLog` and optionally printed.
6. Returns a summary result set with columns: `DatabaseName`, `TotalProcessed`, `SuccessCount`, `ErrorCount`, `DurationSeconds`, `StartTime`, `EndTime`, `OverallStatus`.

### Key design points

| Aspect | Detail |
|---|---|
| Error handling | Per-table `TRY/CATCH`; respects `@ContinueOnError` flag |
| Schema creation | Auto-creates missing schemas in the target database |
| Idempotency | Always drops and re-creates, so re-runs are safe |
| Ordering | Alphabetical by `schema_name`, `table_name` (not dependency-ordered; dimension tables must be in Tier 1 before facts that depend on them) |

---

## 2. Presentation table DDL definitions

**Source file:** `8_PresentationTables.sql` (1,625 lines)
**Total records:** 24 (as stated in the file header, generated 2026-01-19)

All tables reside in the `presentation` schema. The file inserts rows into `core.PresentationTables`; `DeployPresentationTables` later materialises those rows as physical tables in the organisation database.

### 2.1 Dimension tables (D_* and supporting)

#### Standard hierarchy dimension template

Twelve dimension tables share a common three-tier flattened hierarchy structure. Every column is `NULL`-tolerant. The columns follow this pattern:

| Column group | Columns |
|---|---|
| Bottom level (leaf node) | `BOTTOM_HUB_ID` `[binary](32)`, `BOTTOM_SRC`, `BOTTOM_LOAD_TS`, `BOTTOM_EFFECTIVEFROM`, `BOTTOM_EFFECTIVETO`, `BOTTOM_CURRENT_FLAG`, `BOTTOM_IS_DELETED`, `BOTTOM_{ENTITY}_NAME`, `BOTTOM_{ENTITY}_ID`, `BOTTOM_LEVEL_NAME`, `BOTTOM_ATTR_1..5`, `BOTTOM_MICROSERVICE_ID`, `BOTTOM_MICROSERVICE_NAME` |
| Middle level 1 (intermediate) | `MIDDLE_1_NAME`, `MIDDLE_1_LEVEL_NAME`, `MIDDLE_1_ATTR_1..5`, `MIDDLE_1_MICROSERVICE_ID`, `MIDDLE_1_MICROSERVICE_NAME` |
| Top level (root) | `TOP_NAME`, `TOP_LEVEL_NAME`, `TOP_ATTR_1..5`, `TOP_MICROSERVICE_ID`, `TOP_MICROSERVICE_NAME` |
| Hierarchy metadata | `HIERARCHY_PATH` `[nvarchar](255)`, `TOTAL_LEVELS` `[decimal](38,10)` |

The following 14 dimensions follow this template exactly, differentiated only by their entity-specific name and ID columns:

| Table | Entity column names | Version | Notes |
|---|---|---|---|
| `D_CHANNEL` | `BOTTOM_CHANNEL_NAME`, `BOTTOM_CHANNEL_ID` | v4 | |
| `D_DEAL` | `BOTTOM_DEAL_NAME`, `BOTTOM_DEAL_ID` | v4 | |
| `D_DISCOUNT` | `BOTTOM_DISCOUNT_NAME`, `BOTTOM_DISCOUNT_ID`, `BOTTOM_VALUE_TYPE`, `BOTTOM_VALUE` | v3 | Extra value fields; MICROSERVICE_ID is `uniqueidentifier` not `nvarchar` |
| `D_DISTRIBUTOR` | `BOTTOM_DISTRIBUTOR_NAME`, `BOTTOM_DISTRIBUTOR_ID` | v3 | |
| `D_INVITEM` | `BOTTOM_INVITEM_NAME`, `BOTTOM_INVITEM_ID` | v3 | Inventory item dimension |
| `D_LOCATION` | `BOTTOM_LOCATION_NAME`, `BOTTOM_LOCATION_ID` | v3 | |
| `D_MOD` | `BOTTOM_MOD_NAME`, `BOTTOM_MOD_ID` | v3 | Modifier dimension |
| `D_OCCASION` | `BOTTOM_OCCASION_NAME`, `BOTTOM_OCCASSION_ID` | v3 | Note: `BOTTOM_OCCASSION_ID` has a double-S — this is a baked-in schema typo |
| `D_PRODUCT` | `BOTTOM_PRODUCT_NAME`, `BOTTOM_PRODUCT_ID` | v3 | |
| `D_REVCENTER` | `BOTTOM_NAME`, `BOTTOM_ID` | v1 | Revenue centre dimension |
| `D_SERVICECHARGE` | `BOTTOM_SVCCHARGE_NAME`, `BOTTOM_SVC_ID` | v3 | Service charge dimension |
| `D_TAX` | `BOTTOM_TAX_NAME`, `BOTTOM_TAX_ID` | v3 | |
| `D_SUPPLIER` | `BOTTOM_SUPPLIER_NAME`, `BOTTOM_SUPPLIER_ID` | v3 | |
| `D_TENDER` | `BOTTOM_TENDER_NAME`, `BOTTOM_TENDER_ID` | v3 | Tender/payment type |

#### CALENDAR

| Column | Type | Nullable | Notes |
|---|---|---|---|
| `Date` | `DATE` | PK | |
| `Year`, `Quarter`, `Month` | `INT` | NOT NULL | |
| `MonthName` | `VARCHAR(20)` | NOT NULL | |
| `Week`, `DayOfYear`, `DayOfMonth`, `DayOfWeek` | `INT` | NOT NULL | |
| `DayName` | `VARCHAR(20)` | NOT NULL | |
| `IsWeekend`, `IsWeekday` | `BIT` | NOT NULL | |
| `SameDayLastWeek`, `SameDayLastYear` | `DATE` | NULL | Comparative date references |
| `IsHoliday_GB/FR/DE/IT/ES/NL/BE/SE/NO/DK/FI/PL/IE` | `BIT DEFAULT 0` | | European country holiday flags |
| `IsHoliday_US/CA/MX/BR/AR` | `BIT DEFAULT 0` | | American country holiday flags |

#### DimCustomer (v2)

A simpler customer dimension, not following the standard three-tier template:

| Column | Type |
|---|---|
| `CustomerKey` | `INT IDENTITY` PK |
| `CustomerID` | `NVARCHAR(50)` NOT NULL |
| `CustomerName` | `NVARCHAR(255)` NOT NULL |
| `Email`, `Phone` | `NVARCHAR` |
| `Address`, `City`, `State`, `State2`, `Country`, `PostalCode` | `NVARCHAR` |
| `IsActive` | `BIT DEFAULT 1` |
| `CreatedDate`, `ModifiedDate` | `DATETIME2 DEFAULT GETDATE()` |

#### D_COOCCURRENCE

Product co-occurrence matrix dimension. Has a **clustered index** on `(PRODUCT_HUB_ID, PRODUCT_HUB_ID_COMP)` and four non-clustered indexes on the contextual hub IDs.

| Column | Type | Nullable |
|---|---|---|
| `PRODUCT_HUB_ID` | `[binary](32)` | NOT NULL |
| `PRODUCT_HUB_ID_COMP` | `[binary](32)` | NOT NULL |
| `OCCASION_HUB_ID` | `[binary](32)` | NULL |
| `LOCATION_HUB_ID` | `[binary](32)` | NULL |
| `REVCENTER_HUB_ID` | `[binary](32)` | NULL |
| `CHANNEL_HUB_ID` | `[binary](32)` | NULL |
| `globalOccurenceCount` | `INT` | NULL |
| `DistinctOrderCount` | `INT` | NULL |

#### E_COOCCUR_BASE

An intermediate staging table for the co-occurrence calculation. Has a **unique clustered index** on all six columns.

| Column | Type |
|---|---|
| `HEADER_ID` | `[nvarchar](255)` |
| `OCCASION_HUB_ID`, `LOCATION_HUB_ID`, `REVCENTER_HUB_ID`, `CHANNEL_HUB_ID` | `[binary](32)` nullable |
| `PRODUCT_HUB_ID` | `[binary](32)` NOT NULL |

### 2.2 Fact tables

All fact tables use `[binary](32)` foreign keys pointing back to the hub IDs in the dimension tables. A clustered index on `(date_column ASC, LOCATION_HUB_ID ASC)` exists on each.

#### F_LINEITEM_15MIN (v3)

Core sales fact. 15-minute aggregated line-item data. 10 non-clustered indexes (one per dimension foreign key).

| Column | Type | Notes |
|---|---|---|
| `SRC` | `[nvarchar](255)` NOT NULL | Source integration |
| `LI_TYPE` | `[nvarchar](255)` NOT NULL | `PROD`, `TENDER`, `DISCOUNT`, etc. |
| `DEAL_HUB_ID`, `DISCOUNT_HUB_ID`, `EMPLOYEE_HUB_ID`, `MOD_HUB_ID`, `OCCASION_HUB_ID`, `PRODUCT_HUB_ID`, `SVCCHARGE_HUB_ID`, `TAX_HUB_ID`, `LOCATION_HUB_ID`, `REVCENTER_HUB_ID`, `CHANNEL_HUB_ID` | `[binary](32)` NOT NULL | Sentinel `-999` value used for NULLs |
| `GROSS_VALUE`, `TAX_VALUE`, `NET_VALUE`, `ORDER_COUNT`, `QUANTITY`, `QUANTITY_INV` | `[decimal](38,10)` | Aggregated measures |
| `LINEITEM_TIMESTAMP` | `[datetime]` | Truncated to 15-minute bucket |
| `ORDER_DATE` | `[datetime2](7)` | Partition / clustering key |

#### F_PRODUCT_MARGIN_DAY (v1)

Daily product margin fact. Derived from line items joined to the product price/cost link table.

| Column | Type |
|---|---|
| `PRODUCT_HUB_ID`, `OCCASION_HUB_ID`, `LOCATION_HUB_ID`, `REVCENTER_HUB_ID`, `CHANNEL_HUB_ID`, `DEAL_HUB_ID`, `DISCOUNT_HUB_ID` | `[binary](32)` NOT NULL |
| `ORDER_DATE` | `[datetime2](7)` |
| `DEAL_FLAG` | `INT` |
| `NET_VALUE`, `QUANTITY`, `AVG_NET_COST`, `AVG_NET_PRICE_CHARGED`, `AVG_NET_PRICE`, `PROFIT`, `PROFIT_LESS_DISCOUNT` | `[decimal](38,10)` |

#### F_INV_COUNTS_DAY (v1)

Daily inventory count fact. Clustered on `(COUNT_DATE, LOCATION_HUB_ID)` with a non-clustered index on `INVITEM_HUB_ID`.

| Column | Type |
|---|---|
| `LOCATION_HUB_ID`, `INVITEM_HUB_ID` | `[binary](32)` NOT NULL |
| `COUNT_DATE` | `[datetime2](7)` |
| `STANDARDISED_UOM` | `[varchar](255)` |
| `PREVIOUS_COUNT`, `ACTUAL_COUNT`, `THEO_QTY`, `THEO_USAGE`, `ACTUAL_USAGE`, `VARIANCE` | `[decimal](38,6)` |
| `ORDER_QTY`, `SALE_QTY`, `PRODUCTION_QTY`, `TRANSFER_QTY`, `WASTE_QTY`, `MOVEMENT_QTY` | `[decimal](38,6)` |
| `UOM_COST` | `[decimal](38,6)` |
| `DAYS_SINCE_LAST_COUNT` | `INT` |

#### F_INV_USAGE_DAY (v1)

Daily inventory usage summary. Clustered on `(COUNT_DATE, LOCATION_HUB_ID)`.

| Column | Type |
|---|---|
| `LOCATION_HUB_ID`, `INVITEM_HUB_ID` | `[binary](32)` NOT NULL |
| `COUNT_DATE` | `[datetime2](7)` |
| `STANDARDISED_UOM` | `[varchar](255)` |
| `THEO_USAGE`, `ORDER_QTY`, `SALE_QTY`, `PRODUCTION_QTY`, `TRANSFER_QTY`, `WASTE_QTY` | `[decimal](38,6)` NOT NULL |
| `UOM_COST` | `[decimal](38,6)` NULL |

#### F_INV_SALES_DAY (v1)

Daily inventory sales bridge. Clustered on `(INV_DATE, LOCATION_HUB_ID)`.

| Column | Type |
|---|---|
| `INVITEM_HUB_ID`, `LOCATION_HUB_ID` | `[binary](32)` |
| `INV_DATE` | `[datetime2](7)` |
| `UOM_COST`, `SALES_RECIPE_COST`, `NET_SALES` | `[decimal](38,6)` |

#### FORECAST_ACTUALS_BASE (v2)

Forecast feature engineering table. Contains 40+ columns including rolling averages, lag features, and weather indicators for ML model training and serving.

| Column group | Key columns |
|---|---|
| Identifiers | `location_hub_id [binary](32)`, `product_category [nvarchar](255)`, `sale_date DATE` NOT NULL |
| Calendar dimensions | `year`, `month`, `day`, `day_of_week`, `day_name`, `week_of_year`, `is_weekend` |
| Targets | `target_quantity`, `target_revenue [decimal](38,10)`, `target_transactions INT` |
| Derived metrics | `avg_ticket_size`, `items_per_transaction`, `revenue_per_item` |
| Quantity rolling averages | `qty_ma_7day`, `qty_ma_14day`, `qty_ma_28day` |
| Quantity lags | `qty_lag_1day`, `qty_lag_7day`, `qty_lag_28day`, `qty_same_dow_last_week` |
| Revenue features | `revenue_ma_7day`, `revenue_ma_28day`, `revenue_lag_1day`, `revenue_lag_7day` |
| Transaction features | `txn_ma_7day`, `txn_ma_28day`, `txn_lag_1day`, `txn_lag_7day` |
| Holiday indicators | `is_holiday`, `holiday_name`, `is_day_before_holiday`, `is_day_after_holiday` |
| Weather | `temperature_avg`, `temperature_high`, `temperature_low`, `precipitation_cm`, `precipitation_probability`, `weather_condition`, `is_severe_weather` |

---

## 3. PresentationControl records and build steps

**Source file:** `8_PresentationControl.sql` (5,206 lines)
**Total records:** 22 (generated 2026-01-19)

Each record in `core.PresentationControl` defines one ETL step. The procedure that executes these steps reads them from the table and executes `query_sql` via `sp_executesql`, writing results into the named `table_name`.

### 3.1 Control record structure

| Column | Purpose |
|---|---|
| `id` | GUID primary key |
| `step_name` | Human-readable label |
| `table_name` | Target presentation table |
| `query_sql` | Full SELECT query that builds the table content |
| `tier` | Execution tier (1 = no dependencies; 2 = depends on Tier 1 output) |
| `table_type` | `Dimension` or `Fact` |
| `column_mappings` | JSON array mapping query columns to table columns with type casting info |
| `exclude` | `0` = active, `1` = skip |
| `priority` | Ordering within tier (100 = default) |
| `retry_count` | Number of retry attempts on failure (3) |
| `timeout_minutes` | Query timeout (30) |
| `description` | Human-readable description of the build step |
| `created_by` | Author of the record |
| `created_at` | Record creation timestamp |
| `updated_at` | Last modification timestamp |
| `time_series_entity` | Identifies the time-series source (`LINEITEM`, `STOCKEVENT`, `None`, or NULL) |
| `time_series_target_column` | The column holding the date key for partitioned loads |

### 3.2 All 22 build steps

#### Tier 1 — Dimensions (no intra-tier dependencies)

| # | Step name | Target table | Source entities | Notes |
|---|---|---|---|---|
| 1 | Channel Dimension | `D_CHANNEL` | `datavault.SAT_CHANNEL` | Recursive CTE hierarchy; sentinel Unknown row appended |
| 2 | CoOccurrence data prep | `E_COOCCUR_BASE` | `datavault.SAT_LINEITEM`, `LNK_LINEITEM_PRODUCT`, `SAT_PRODUCT`, `LNK_LINEITEM_OCCASION`, `LNK_CUSTORDER_*` | Rolling 180-day window; TOP 100 products only |
| 3 | Deal Dimension | `D_DEAL` | `datavault.SAT_DEAL` | Recursive CTE + sentinel |
| 4 | Discount Dimension | `D_DISCOUNT` | `datavault.SAT_DISCOUNT` | Recursive CTE + sentinel |
| 5 | Distributor Dimension | `D_DISTRIBUTOR` | `datavault.SAT_DISTRIBUTOR` | Recursive CTE + sentinel |
| 6 | F_LINEITEM_15MIN | `F_LINEITEM_15MIN` | `SAT_LINEITEM`, `LNK_DEAL_LINEITEM`, `LNK_DISCOUNT_LINEITEM`, `LNK_EMPLOYEE_LINEITEM`, `LNK_LINEITEM_MOD`, `LNK_LINEITEM_OCCASION`, `LNK_LINEITEM_PRODUCT`, `LNK_LINEITEM_SVCCHARGE`, `LNK_LINEITEM_TAX`, `LNK_CUSTORDER_LINEITEM`, `SAT_CUSTORDER`, `LNK_CUSTORDER_LOCATION`, `LNK_CUSTORDER_REVCENTER`, `LNK_CHANNEL_CUSTORDER`, `core.Integrations` | Date range from `GlobalParameters` keys `LINEITEM_START`/`LINEITEM_END`; 15-min bucket via `DATEADD`/`DATEDIFF`; sentinel `-999` for NULL hub IDs |
| 7 | Forecast Actuals Base | `FORECAST_ACTUALS_BASE` | `SAT_LINEITEM`, `LNK_LINEITEM_PRODUCT`, `presentation.D_PRODUCT`, `LNK_CUSTORDER_*`, `presentation.CALENDAR` | Complex CTE chain: DailySales → LocationCategories → Calendar → CompleteData → FeaturesData with window-function rolling averages and lag columns |
| 8 | Inv Item Dimension | `D_INVITEM` | `datavault.SAT_INVITEM` | Recursive CTE + sentinel |
| 9 | Inventory Counts by Day | `F_INV_COUNTS_DAY` | `datavault.SAT_STOCKEVENT_*`, inventory link tables | Date range from `STOCKEVENT_START`/`STOCKEVENT_END` |
| 10 | Inventory Usage by Day | `F_INV_USAGE_DAY` | Inventory datavault entities | STOCKEVENT date range |
| 11 | Location Dimension | `D_LOCATION` | `datavault.SAT_LOCATION` | Recursive CTE + sentinel |
| 12 | Mod Dimension | `D_MOD` | `datavault.SAT_MOD` | Recursive CTE + sentinel |
| 13 | Occasion Dimension | `D_OCCASION` | `datavault.SAT_OCCASION` | Recursive CTE + sentinel |
| 14 | Product Dimension | `D_PRODUCT` | `datavault.SAT_PRODUCT` | Recursive CTE + sentinel |
| 15 | Product Margins by Day | `F_PRODUCT_MARGIN_DAY` | `SAT_LINEITEM`, `LNK_LINEITEM_LINEITEM`, `SAT_LNK_LINEITEM_LINEITEM`, `LNK_LINEITEM_PRODUCT`, `SAT_PRODUCT`, `LNK_LOCATION_OCCASION_PRODUCT`, `SAT_LNK_LOCATION_OCCASION_PRODUCT`, `core.Integrations` | Multi-CTE: ProductBase → LinkData → ProductPrice (cross-source price fill) → Final → aggregated SELECT; reads `LINEITEM_START`/`LINEITEM_END` |
| 16 | Revenue Center Dimension | `D_REVCENTER` | `datavault.SAT_REVCENTER` | Recursive CTE + sentinel |
| 17 | Service Charge Dimension | `D_SERVICECHARGE` | `datavault.SAT_SVCCHARGE` | Recursive CTE + sentinel |
| 18 | Supplier Dimension | `D_SUPPLIER` | `datavault.SAT_SUPPLIER` (or equivalent) | Recursive CTE + sentinel |
| 19 | TAX Dimension | `D_TAX` | `datavault.SAT_TAX` | Recursive CTE + sentinel |
| 20 | Tender Dimension | `D_TENDER` | `datavault.SAT_TENDER` | Recursive CTE + sentinel |

#### Tier 2 — Tables that depend on Tier 1 output

| # | Step name | Target table | Depends on | Notes |
|---|---|---|---|---|
| 21 | Inventory Sales by Day | `F_INV_SALES_DAY` | `presentation.F_INV_USAGE_DAY` | Joins `F_INV_USAGE_DAY` with POS line-item product sales; UOM conversion CTE embedded (gr, Kg, lb, oz, ml, cl, L, Imperial Pint, Gal, EA); reads `STOCKEVENT_START/END` |
| 22 | Product CoOccurrence Dimension | `D_COOCCURRENCE` | `presentation.E_COOCCUR_BASE` | Self-join on `E_COOCCUR_BASE` to count co-occurring product pairs per order; filtered to pairs with at least 1 distinct order |

### 3.3 SQL patterns used in PresentationControl

#### Recursive CTE hierarchy flattening

Used by all 14 standard dimension build steps. The pattern always has four named CTEs:

```sql
WITH HierarchyPath AS (
    -- Anchor: bottom-level records (BOTTOM_LEVEL = 1, CURRENT_FLAG = 1)
    SELECT HUB_ID, ..., ENTITY_ID as ROOT_ENTITY_ID, 0 as LEVEL_DEPTH,
           CAST(ENTITY_ID as VARCHAR(MAX)) as PATH
    FROM [datavault].[SAT_ENTITY]
    WHERE BOTTOM_LEVEL = 1 AND CURRENT_FLAG = 1
    UNION ALL
    -- Recursive: traverse UP the hierarchy by joining ENTITY_ID = PARENT_ID
    SELECT d.HUB_ID, ..., h.ROOT_ENTITY_ID,
           h.LEVEL_DEPTH + 1 as LEVEL_DEPTH,
           h.PATH + '->' + CAST(d.ENTITY_ID as VARCHAR(MAX)) as PATH
    FROM [datavault].[SAT_ENTITY] d
    INNER JOIN HierarchyPath h ON d.ENTITY_ID = h.PARENT_ID
    WHERE d.CURRENT_FLAG = 1
),
NumberedHierarchy AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY ROOT_ENTITY_ID ORDER BY LEVEL_DEPTH) as RN
    FROM HierarchyPath
),
FilteredHierarchy AS (
    SELECT *, MAX(LEVEL_DEPTH) OVER (PARTITION BY ROOT_ENTITY_ID) as MAX_LEVEL
    FROM NumberedHierarchy
),
SelectedLevels AS (
    SELECT * FROM FilteredHierarchy
    WHERE LEVEL_DEPTH = 0          -- Bottom leaf
       OR PARENT_ID IS NULL        -- Top root
       OR (LEVEL_DEPTH > 0 AND LEVEL_DEPTH < MAX_LEVEL AND RN <= @MiddleLevels + 1)
)
-- Pivot to flat columns using conditional MAX(CASE WHEN LEVEL_DEPTH = 0 ...)
SELECT
    MAX(CASE WHEN LEVEL_DEPTH = 0 THEN HUB_ID END) as BOTTOM_HUB_ID,
    ...
    COALESCE(MAX(CASE WHEN RN = 2 AND PARENT_ID IS NOT NULL THEN ENTITY_NAME END),
             MAX(CASE WHEN PARENT_ID IS NULL THEN ENTITY_NAME END),
             'All ENTITYs') as MIDDLE_1_NAME,
    ...
    COALESCE(MAX(CASE WHEN PARENT_ID IS NULL THEN ENTITY_NAME END), 'All ENTITYs') as TOP_NAME,
    MAX(PATH) as HIERARCHY_PATH,
    MAX(MAX_LEVEL) as TOTAL_LEVELS
FROM SelectedLevels
GROUP BY ROOT_ENTITY_ID
UNION ALL
-- Sentinel 'Unknown' row with CONVERT(BINARY(32), -999) as hub key
SELECT CONVERT(BINARY(32), -999) AS BOTTOM_HUB_ID, 'Unknown' AS BOTTOM_..., ...
```

#### Null-safe sentinel joins

Foreign keys that cannot be resolved at load time are replaced with the sentinel value `CONVERT(BINARY(32), -999)`:

```sql
ISNULL(DEAL.[DEAL_HUB_ID], CONVERT(BINARY(32), -999)) AS [DEAL_HUB_ID]
```

Every dimension table includes a corresponding `UNION ALL` sentinel row with `CONVERT(BINARY(32), -999)` as its `BOTTOM_HUB_ID` and the string `'Unknown'` for descriptive columns. This ensures every fact row has a matching dimension row even when source data is incomplete.

#### Date range from GlobalParameters

Fact steps read their date window from the `core.GlobalParameters` table:

```sql
SELECT @StartDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = 'LINEITEM_START';

SELECT @EndDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = 'LINEITEM_END';
```

Keys used: `LINEITEM_START`, `LINEITEM_END` (POS data), `STOCKEVENT_START`, `STOCKEVENT_END` (inventory data).

#### 15-minute timestamp bucketing

```sql
DATEADD(MINUTE,
    (DATEDIFF(MINUTE, 0, LI.[LINEITEM_TIMESTAMP]) / 15) * 15,
    0) AS [LINEITEM_TIMESTAMP]
```

#### Window-function feature engineering (FORECAST_ACTUALS_BASE)

```sql
AVG(quantity * 1.0) OVER (
    PARTITION BY location_hub_id, product_category
    ORDER BY sale_date
    ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
) as qty_ma_7day
```

Similar patterns generate 14-day and 28-day moving averages, standard deviations, and lag columns (`LAG()` over the same partition).

### 3.4 Datavault-to-presentation entity mapping

| Datavault source entity | Presentation target |
|---|---|
| `SAT_CHANNEL` | `D_CHANNEL` |
| `SAT_DEAL` | `D_DEAL` |
| `SAT_DISCOUNT` | `D_DISCOUNT` |
| `SAT_DISTRIBUTOR` | `D_DISTRIBUTOR` |
| `SAT_INVITEM` | `D_INVITEM` |
| `SAT_LOCATION` | `D_LOCATION` |
| `SAT_MOD` | `D_MOD` |
| `SAT_OCCASION` | `D_OCCASION` |
| `SAT_PRODUCT` | `D_PRODUCT` |
| `SAT_REVCENTER` | `D_REVCENTER` |
| `SAT_SVCCHARGE` | `D_SERVICECHARGE` |
| `SAT_SUPPLIER` | `D_SUPPLIER` |
| `SAT_TAX` | `D_TAX` |
| `SAT_TENDER` | `D_TENDER` |
| `SAT_LINEITEM` + 10 link tables | `F_LINEITEM_15MIN` |
| `SAT_LINEITEM` + `LNK_LINEITEM_LINEITEM` + `LNK_LOCATION_OCCASION_PRODUCT` + `SAT_LNK_*` | `F_PRODUCT_MARGIN_DAY` |
| `SAT_STOCKEVENT_*` + inventory links | `F_INV_COUNTS_DAY`, `F_INV_USAGE_DAY` |
| `F_INV_USAGE_DAY` + `SAT_LINEITEM` (INVENTORY type) | `F_INV_SALES_DAY` |
| `SAT_LINEITEM` + `LNK_LINEITEM_PRODUCT` + `CALENDAR` + `D_PRODUCT` | `FORECAST_ACTUALS_BASE` |
| `SAT_LINEITEM` + product links | `E_COOCCUR_BASE` |
| `E_COOCCUR_BASE` (self-join) | `D_COOCCURRENCE` |

---

## 4. Visualisation queries

**Source file:** `8_VisualisationQueries.sql` (21,520 lines, ~553 KB)
**Total records:** 109
**Unique datasets:** 89 (as stated in the file header, generated 2026-01-20)

Records are inserted into `core.core.VisualisationQueries`. Every query is matched at runtime to a card-type stored procedure which executes the `ExecutionQuery` field after injecting the dynamic `@FilterClause`.

### 4.1 VisualisationQueries table structure

| Column | Purpose |
|---|---|
| `DataSetName` | Unique name used as `@DataSet` parameter when calling card procedures |
| `VisualizationType` | Maps to the stored procedure that will execute this query |
| `Version` | All current records are Version 1 |
| `Status` | `LIVE` = active; only LIVE records are selected by card procedures |
| `QueryTemplate` | SQL with `@FilterClause` placeholder; date/location filters not yet injected |
| `ExecutionQuery` | Pre-aliased version of `QueryTemplate` with output column aliases matching the `OutputDefinitions` column_mappings |
| `ParameterMappings` | JSON object mapping standard parameters (`StartDate`, `EndDate`, `LocationList`) to SQL column expressions |
| `FilterDefinitions` | JSON object defining available filter dimensions with their `column`, `type` (always `IN`), and `dataType` |
| `OutputDefinitions` | JSON object defining `column_mappings` (query alias to output name) and `additional_datasets` (supplementary result sets such as `Header`) |
| `Description`, `CreatedBy`, `ModifiedBy`, `CreatedDate`, `ModifiedDate` | Audit fields |

### 4.2 ParameterMappings structure

```json
{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}
```

The `BuildDynamicWhereClause` procedure reads these to construct `AND {StartDate column} >= '{StartDate}'` etc.

### 4.3 FilterDefinitions structure

Each filter key corresponds to a dimension. All filters use type `IN`:

```json
{
  "Channels":          { "column": "COALESCE(channel.[BOTTOM_MICROSERVICE_NAME],channel.[BOTTOM_CHANNEL_NAME])", "type": "IN", "dataType": "VARCHAR" },
  "Discounts":         { "column": "...", "type": "IN", "dataType": "VARCHAR" },
  "ProductCategories": { "column": "product.[MIDDLE_1_NAME]", "type": "IN", "dataType": "VARCHAR" },
  "Products":          { "column": "COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])", "type": "IN", "dataType": "VARCHAR" },
  "DayOfWeek":         { "column": "DATENAME(WEEKDAY, F.[ORDER_DATE])", "type": "IN", "dataType": "VARCHAR" },
  "SurveyFilter":      { "column": "", "type": "IN", "dataType": "VARCHAR" },
  "SurveyFilterAge":   { "column": "", "type": "IN", "dataType": "VARCHAR" }
}
```

Survey-specific filter columns are left empty because survey queries have their own direct filter logic.

### 4.4 OutputDefinitions structure

```json
{
  "column_mappings": {
    "Label":  "Label1",
    "Value":  "Value1",
    "ID":     "ID1",
    "Axis":   "Axis1",
    "AxisSort": "AxisSort1"
  },
  "additional_datasets": [
    {
      "name": "Header",
      "type": "Header",
      "columns": ["Title", "Description", "Value"],
      "values": { "Title": "Chart Title", "Description": "Chart Description" }
    }
  ]
}
```

Many queries include a second `SELECT` statement as an `additional_dataset` of type `Header` to supply the card title, description, trend value, and chip label.

### 4.5 Card types (VisualizationType values)

| Card type | Count | Typical output shape |
|---|---|---|
| `BarChartCard` | 9 | `Label`, `Value` (and optionally `Category`) |
| `LineChartCard` | 1 | `Label`, `Value`, time series |
| `PieChartCard` | 12 | `Label`, `Value`, `Id`, `Curve`, `Stack`, `Area`, `StackOrder` |
| `SingleKPICard` | 17 | Single numeric value with header dataset |
| `StatCard` | 3 | Multiple KPI statistics in one card |
| `CustomDataGrid` | 10 | Tabular rows; columns mapped in OutputDefinitions |
| `CustomGroupedDataGrid` | 3 | Tabular with grouping |
| `CustomPinnedDataGrid` | 3 | Tabular with pinned header row |
| `HeatmapCard` | 3 | `Row`, `Column`, `Value` |
| `CombinedChartCard` | 7 | Mixed bar+line; multiple series columns |
| `MultiLineChartCard` | 4 | Multiple series on one chart |
| `StackedBarChartCard` | 9 | `Label`, `Value`, `Stack` grouping |
| `TreeViewCard` | 0 | Hierarchical tree (procedure deployed, no active records) |
| `RadarChartCard` | 7 | `Axis`, `AxisSort`, `Label`, `Value` |
| `MarkdownCard` | 0 | Free-text markdown (procedure deployed, no active records) |
| `FilterList` | 21 | `Label`, `ID`, `ParentID`, `BottomLevel` for dropdown population |

**Total: 109 records.**

### 4.6 Complete dataset catalogue

The 89 unique dataset names are listed below, grouped by subject area.

#### Sales and revenue (POS)

| Dataset | Card type | Description |
|---|---|---|
| `GrossATV` | `SingleKPICard` + `StatCard` | Average transaction value (gross) |
| `GrossDiscount` | `SingleKPICard` | Total gross discount value |
| `NetSales` | `CombinedChartCard` + `BarChartCard` + `MultiLineChartCard` + `SingleKPICard` + `StackedBarChartCard` + `StatCard` | Net revenue across multiple chart types |
| `NetSalesByHour` | `CombinedChartCard` | Net sales broken down by hour of day |
| `SalesKPI` | `CustomDataGrid` + `CustomGroupedDataGrid` | Multi-metric sales KPI table |
| `SalesKPIGrouped` | `CustomGroupedDataGrid` | Grouped KPI view |
| `TotalOrders` | `SingleKPICard` | Count of distinct orders |
| `ProdMarg` | `StackedBarChartCard` | Product margin summary |

#### Transactions and order patterns

| Dataset | Card type | Description |
|---|---|---|
| `ATVChannelDayPart` | `RadarChartCard` | ATV by channel across hourly day-parts |
| `ATVRevCentreDayPart` | `RadarChartCard` | ATV by revenue centre across day-parts |
| `DayOfWeek` | `FilterList` | Day-of-week filter values |
| `OrderRevCentreDayPart` | `CombinedChartCard` | Order counts by revenue centre and hour |
| `OrdersChannelDayPart` | `RadarChartCard` | Orders by channel and hour |

#### Products

| Dataset | Card type | Description |
|---|---|---|
| `ProductCategories` | `FilterList` | Product category filter values |
| `ProductCount` | `BarChartCard` + `PieChartCard` + `SingleKPICard` | Product sale counts |
| `ProductGC` | `HeatmapCard` | Product gross contribution heatmap |
| `ProductMargins` | `CombinedChartCard` + `MultiLineChartCard` + `PieChartCard` + `StackedBarChartCard` | Margin analysis by product |
| `ProductMarginsChannel` | `CombinedChartCard` + `CustomPinnedDataGrid` | Margins broken down by channel |
| `ProductNetSales` | `CustomPinnedDataGrid` | Net sales per product grid |
| `Products` | `FilterList` | Product filter values |
| `ProductsComp` | `FilterList` | Product comparison filter values |

#### Discounts and deals

| Dataset | Card type | Description |
|---|---|---|
| `DealToggle` | `FilterList` | Deal on/off filter |
| `Deals` | `FilterList` | Deal dimension filter values |
| `DiscountPerc` | `SingleKPICard` + `StatCard` | Discount as percentage of revenue |
| `Discounts` | `BarChartCard` + `FilterList` + `LineChartCard` | Discount value over time and by type |
| `DiscountsRevCentreDayPart` | `CombinedChartCard` | Discounts by rev centre and day-part |

#### Dimensions / filter lists

| Dataset | Card type | Description |
|---|---|---|
| `Channels` | `FilterList` | Channel dimension filter |
| `Integrations` | `FilterList` | Available integration sources |
| `Locations` | `FilterList` | Location filter values |
| `Mods` | `FilterList` | Modifier filter values |
| `Occasions` | `FilterList` | Occasion filter values |
| `RevenueCentres` | `FilterList` | Revenue centre filter |
| `ServiceCharges` | `FilterList` | Service charge filter |
| `Suppliers` | `FilterList` | Supplier filter |
| `Tax` | `FilterList` | Tax dimension filter |
| `TaxTotal` | `SingleKPICard` | Total tax collected |
| `Tenders` | `FilterList` | Tender type filter |
| `Distributors` | `FilterList` | Distributor filter |

#### Inventory

| Dataset | Card type | Description |
|---|---|---|
| `InvActMargin` | `PieChartCard` | Actual inventory margin (cost vs. revenue) |
| `InvCountData` | `CustomDataGrid` | Raw inventory count data grid |
| `InvItems` | `FilterList` | Inventory item filter |
| `InvKPIGrouped` | `CustomGroupedDataGrid` | Grouped inventory KPIs |
| `InvNegVar` | `SingleKPICard` | Total negative inventory variance |
| `InvNetSales` | `SingleKPICard` | Inventory-derived net sales |
| `InvOrdersCost` | `SingleKPICard` | Total ordering cost |
| `InvPosVar` | `SingleKPICard` | Total positive variance |
| `InvProdEventCost` | `SingleKPICard` | Production event cost |
| `InvProdEventValue` | `SingleKPICard` | Production event value |
| `InvRecipeMargin` | `PieChartCard` | Recipe cost vs. margin split |
| `InvTheoMargin` | `PieChartCard` | Theoretical margin vs. actual |
| `InvVariances` | `StackedBarChartCard` | Variance breakdown by type |
| `InvWasteCost` | `SingleKPICard` | Total waste cost |

#### Forecasting

| Dataset | Card type | Description |
|---|---|---|
| `ForecastDailyRevenue` | `CombinedChartCard` + `MultiLineChartCard` | Actual vs. forecast daily revenue |
| `ForecastProductQuantity` | `MultiLineChartCard` + `PieChartCard` + `StackedBarChartCard` | Actual vs. forecast product quantity by category |

#### Survey (SurveyHero integration)

| Dataset | Card type | Description |
|---|---|---|
| `SurveyAgeByGender` | `CustomDataGrid` + `CustomPinnedDataGrid` | Respondent age distribution by gender |
| `SurveyAgeByRespondentTotal` | `BarChartCard` | Age vs. respondent total |
| `SurveyAgeGender` | `HeatmapCard` | Age and gender breakdown heatmap |
| `SurveyAverageChallengeScore` | `PieChartCard` | Average challenge theme score |
| `SurveyAverageLifestyleScore` | `PieChartCard` | Average lifestyle theme score |
| `SurveyBuildingActivities` | `PieChartCard` | Activities held in building |
| `SurveyBuildingSuited` | `PieChartCard` | Building suitability responses |
| `SurveyBuildingUse` | `BarChartCard` + `PieChartCard` | Building use purpose responses |
| `SurveyBuildingUseImprovements` | `SingleKPICard` | Improvement suggestion count |
| `SurveyBuildingUseMessage` | `SingleKPICard` | Key message from building use data |
| `SurveyChallengeThoughts` | `CustomDataGrid` | Challenge theme open-text responses |
| `SurveyChallengeThoughtsnonChurch` | `CustomDataGrid` | Challenge responses for non-church respondents |
| `SurveyChallengingRadar` | `RadarChartCard` | Multi-axis radar of challenge scores |
| `SurveyCompletion` | `StackedBarChartCard` | Survey completion status |
| `SurveyDistanceTransport` | `HeatmapCard` | Distance vs. transport mode heatmap |
| `SurveyEnvironmentRadar` | `RadarChartCard` | Environment theme radar |
| `SurveyEnvironmentRadarBad` | `RadarChartCard` | Environment radar – negative sentiment |
| `SurveyEnvironmentThoughts` | `CustomDataGrid` | Environment open-text responses |
| `SurveyFilter` | `FilterList` | Survey segment filter |
| `SurveyFilterAge` | `FilterList` | Survey age-band filter |
| `SurveyGenderByRespondentTotal` | `PieChartCard` | Gender split of respondents |
| `SurveyImprovementsNeeded` | `CustomDataGrid` | Free-text improvements responses |
| `SurveyLifestyleProvision` | `BarChartCard` | Lifestyle provision ratings |
| `SurveyLifestyleProvisionThoughts` | `CustomDataGrid` | Lifestyle provision open-text |
| `SurveyLifestyleProvisionThoughtsnonChurch` | `CustomDataGrid` | Lifestyle provision (non-church) |
| `SurveyLifestyleRadar` | `RadarChartCard` | Lifestyle theme radar chart |
| `SurveyLifestyleThoughts` | `SingleKPICard` | Key lifestyle metric |
| `SurveyMemberActivities` | `BarChartCard` | Member activity types |
| `SurveyMembersDistance` | `BarChartCard` | Member travel distance distribution |
| `SurveyMembersTravel` | `BarChartCard` | Member travel mode distribution |
| `SurveyRespondentByChallenge` | `StackedBarChartCard` | Respondents cross-tabulated by challenge |
| `SurveyRespondentByEnvironment` | `StackedBarChartCard` | Respondents by environment theme |
| `SurveyRespondentByLifestyle` | `StackedBarChartCard` | Respondents by lifestyle theme |
| `SurveyStatusByInvolvement` | `CustomPinnedDataGrid` | Status cross-tabulated by involvement level |
| `SurveyVisitorMessage` | `CustomDataGrid` | Visitor open-text message responses |

### 4.7 Presentation tables referenced in visualisation queries

Every sales and inventory query joins from one central fact table to dimensions via the `BOTTOM_HUB_ID` foreign key:

```sql
FROM [presentation].[F_LINEITEM_15MIN] F
LEFT JOIN [presentation].[D_DEAL]        deal        ON F.DEAL_HUB_ID        = deal.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_DISCOUNT]    discount    ON F.DISCOUNT_HUB_ID    = discount.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_MOD]         mod         ON F.MOD_HUB_ID         = mod.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_OCCASION]    occasion    ON F.OCCASION_HUB_ID    = occasion.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_PRODUCT]     product     ON F.PRODUCT_HUB_ID     = product.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_SERVICECHARGE] svccharge ON F.SVCCHARGE_HUB_ID   = svccharge.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_TAX]         tax         ON F.TAX_HUB_ID         = tax.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_LOCATION]    location    ON F.LOCATION_HUB_ID    = location.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_REVCENTER]   revcenter   ON F.REVCENTER_HUB_ID   = revcenter.BOTTOM_HUB_ID
LEFT JOIN [presentation].[D_CHANNEL]     channel     ON F.CHANNEL_HUB_ID     = channel.BOTTOM_HUB_ID
INNER JOIN [presentation].[CALENDAR] C               ON F.[ORDER_DATE]        = C.[DATE]
```

Inventory queries use `F_INV_SALES_DAY`, `F_INV_COUNTS_DAY`, or `F_INV_USAGE_DAY` as the driving fact, joined to `D_LOCATION`, `D_INVITEM`, and `CALENDAR`.

Forecast queries read `FORECAST_ACTUALS_BASE`.

The `Integrations` dataset reads directly from `core.core.Integrations` + `sys.schemas`.

### 4.8 SelectQuery SQL patterns

#### Star join with sentinel-safe lookup

All dimension joins use `LEFT JOIN … ON F.{DIM}_HUB_ID = dim.BOTTOM_HUB_ID`. Because unknown dimension rows have `BOTTOM_HUB_ID = CONVERT(BINARY(32), -999)` they always produce a match, yielding `'Unknown'` as the dimension label rather than NULL.

#### @FilterClause injection

```sql
WHERE 1=1
@FilterClause
```

`BuildDynamicWhereClause` replaces `@FilterClause` with zero or more `AND col IN (...)` fragments.

#### COALESCE for MDM name resolution

```sql
COALESCE(channel.[BOTTOM_MICROSERVICE_NAME], channel.[BOTTOM_CHANNEL_NAME]) AS CHANNEL
```

The `MICROSERVICE_NAME` columns serve as a **Master Data Management (MDM) layer** for cross-integration product/item alignment. When a manually-curated MDM name is present it takes priority; otherwise the native dimension name is used. These columns must **never** be populated by automated staging pipelines — they are reserved for manual MDM entry only. If an integration's staging SQL sets `MICROSERVICE_NAME` to a non-null value (e.g. the integration name), all vis queries will resolve to that value instead of real item names.

#### Multi-result-set queries (Header dataset)

Many `ExecutionQuery` values contain two SELECT statements. The first returns the chart data rows; the second returns a single-row Header with the card title, description, trend value, and supplementary metadata:

```sql
-- First result set: chart data
SELECT Label, Value, Id, ...
FROM ... WHERE 1=1 @FilterClause

-- Second result set: header
SELECT 'Net Sales' AS Title, '' AS Description, NULL AS Trend, NULL AS Chip,
       (SELECT SUM(NET_VALUE) FROM ... WHERE 1=1 @FilterClause) AS Value
```

#### Right outer join for sparse radar data (ATVChannelDayPart, ATVRevCentreDayPart, OrdersChannelDayPart)

A Cartesian `CROSS JOIN` of all day-part hours with all dimension members produces a template set. The actual aggregated data is `RIGHT OUTER JOIN`ed onto it, and `ISNULL(ACTUALS.Value, 0)` fills gaps, ensuring the radar chart always has a complete axis:

```sql
SELECT ... ISNULL(ACTUALS.ATV, 0) AS Value1
FROM (...aggregated...) ACTUALS
RIGHT OUTER JOIN
    (SELECT DAY_PERIOD, CHANNEL FROM
        (SELECT DISTINCT DATEPART(HOUR,[LINEITEM_TIMESTAMP]) AS DAY_PERIOD ...) DP
        CROSS JOIN
        (SELECT DISTINCT COALESCE([BOTTOM_MICROSERVICE_NAME],[BOTTOM_CHANNEL_NAME]) AS CHANNEL ...) OT
    ) TEMPLATE
ON ACTUALS.DAY_PERIOD = TEMPLATE.DAY_PERIOD
AND ACTUALS.CHANNEL = TEMPLATE.CHANNEL
```

---

## 5. Card-type stored procedures

**Source file:** `8_Deployment_Objects_Records.sql` (46 objects total)

These procedures are deployed into each organisation schema via the `DeploymentObjects` mechanism. All 16 card procedures share an identical interface and implementation pattern.

### 5.1 Shared interface

```sql
CREATE OR ALTER PROCEDURE {SCHEMA}.[{CardType}]
    @StartDate    DATE          = NULL,
    @EndDate      DATE          = NULL,
    @LocationList NVARCHAR(MAX) = NULL,
    @DataSet      NVARCHAR(100),
    @Filters      NVARCHAR(MAX) = NULL
```

### 5.2 Shared execution pattern

```sql
-- 1. Fetch query and metadata from VisualisationQueries
SELECT
    @SQL                = COALESCE(ExecutionQuery, QueryTemplate),
    @ParameterMappings  = ParameterMappings,
    @FilterDefinitions  = FilterDefinitions
FROM [core].[core].[VisualisationQueries]
WHERE DataSetName = @DataSet
AND VisualizationType = '{CardType}'
AND Status = 'LIVE';

-- 2. Raise error if dataset not found
IF @SQL IS NULL
    RAISERROR('DataSet "%s" not found for {CardType} or inactive', 16, 1, @DataSet);

-- 3. Build dynamic WHERE clause
EXEC {SCHEMA}.[BuildDynamicWhereClause]
    @StartDate, @EndDate, @LocationList, @Filters,
    @ParameterMappings, @FilterDefinitions,
    @FilterClause OUTPUT;

-- 4. Inject filter and execute
SET @SQL = REPLACE(@SQL, '@FilterClause', @FilterClause);
EXEC sp_executesql @SQL;
```

### 5.3 Complete list of card procedures (order 49–64)

| Execution order | Procedure name | Card type description |
|---|---|---|
| 49 | `FilterList` | Dropdown population for filter controls |
| 50 | `BarChartCard` | Vertical or horizontal bar chart |
| 51 | `LineChartCard` | Simple line chart |
| 52 | `PieChartCard` | Pie / donut chart with optional primary/secondary text |
| 53 | `SingleKPICard` | Single large numeric KPI with header |
| 54 | `CustomDataGrid` | Flat tabular grid |
| 55 | `HeatmapCard` | Row/column intensity heatmap |
| 56 | `CombinedChartCard` | Mixed chart (bar + line) |
| 57 | `TreeViewCard` | Hierarchical tree view |
| 58 | `StackedBarChartCard` | Stacked bar chart |
| 59 | `StatCard` | Multi-statistic summary card |
| 60 | `MultiLineChartCard` | Multiple lines on one chart |
| 61 | `CustomGroupedDataGrid` | Grid with group-level rows |
| 62 | `CustomPinnedDataGrid` | Grid with a pinned top-row summary |
| 63 | `RadarChartCard` | Spider/radar chart |
| 64 | `MarkdownCard` | Free-text markdown card |

### 5.4 BuildDynamicWhereClause procedure

**Execution order: 20.** This is the shared filter-building utility called by every card procedure.

```sql
CREATE OR ALTER PROCEDURE {SCHEMA}.[BuildDynamicWhereClause]
    @StartDate         DATE,
    @EndDate           DATE,
    @LocationList      NVARCHAR(MAX),
    @Filters           NVARCHAR(MAX),
    @ParameterMappings NVARCHAR(MAX),
    @FilterDefinitions NVARCHAR(MAX),
    @FilterClause      NVARCHAR(MAX) OUTPUT
```

Logic:

1. Reads `StartDate`, `EndDate`, and `LocationList` column expressions from `@ParameterMappings` JSON.
2. Appends `AND {column} >= '{date}'` and `AND {column} <= '{date}'` clauses.
3. Appends `AND {column} IN ({LocationList})`.
4. Iterates over keys in `@Filters` JSON via `OPENJSON`, looks up each key in `@FilterDefinitions` to obtain the target column and data type, then builds `AND {column} IN (...)` clauses.

### 5.5 Supporting infrastructure objects

| Execution order | Object name | Type | Purpose |
|---|---|---|---|
| 10 | `GlobalParameters` | TABLE | Key-value store for system configuration |
| 15 | `GlobalParameters_Indexes` | INDEX | Category and IsActive indexes |
| 20 | `GetParameter` | FUNCTION | Returns `ParameterValue` by key |
| 21 | `GetParameterWithType` | FUNCTION | Returns value with metadata |
| 22 | `GetParameterDataType` | FUNCTION | Returns the stored DataType |
| 23 | `GetTypedParameter` | FUNCTION | Returns value auto-cast to correct SQL type |
| 30 | `SetParameter` | PROCEDURE | Upsert for GlobalParameters |
| 40 | `SampleData` | SAMPLE_DATA | Inserts default APP_VERSION, MAX_RETRY_ATTEMPTS, MAINTENANCE_MODE, DEFAULT_TIMEOUT, LAST_MAINTENANCE_DATE |
| 100 | `CTL_DV_PROCESS` | TABLE | Data Vault job control |
| 101 | `CTL_STG_PROCESS` | TABLE | Staging job control |
| 102 | `LOG_DV` | TABLE | Data Vault logging |
| 103 | `LOG_STG` | TABLE | Staging logging |
| 104 | `ForecastModels` | TABLE | ML model storage (`VARBINARY(MAX)` for .pkl binaries; metadata JSON; indexed on `location_hub_id`, `product_category`, `model_type`, `is_active`) |

---

## 6. Dynamic suggestion tables

**Source file:** `7_Dynamic Suggestion Tables.sql` (234 lines)

This file creates four tables in the `core` schema that underpin the AI-assisted suggestion and description engine. These tables are not part of the data pipeline but drive automated narrative generation and action recommendations on dashboards.

### 6.1 ActionInferenceRules

Stores rules that detect patterns and generate suggested actions.

| Column | Type | Notes |
|---|---|---|
| `InferenceRuleID` | `INT IDENTITY` PK | |
| `RuleName` | `NVARCHAR(100)` NOT NULL | |
| `SuggestionType` | `NVARCHAR(50)` NOT NULL | |
| `DetectionConditionsJSON` | `NVARCHAR(MAX)` NOT NULL | JSON conditions to evaluate against metric values |
| `EffectivenessConditionsJSON` | `NVARCHAR(MAX)` | Conditions to assess outcome effectiveness |
| `ConfidenceScore` | `INT` | Rule confidence (0–100) |
| `TimeWindowDays` | `INT` | Lookback window for evaluation |
| `RequiresAllConditions` | `BIT DEFAULT 1` | AND vs. OR logic for conditions |
| `Priority` | `INT DEFAULT 50` | Tiebreak ordering |
| `IsActive` | `BIT DEFAULT 1` | |
| `CreatedDate`, `UpdatedDate` | `DATETIME DEFAULT GETDATE()` | |
| `CreatedBy` | `NVARCHAR(100)` | |
| `Notes` | `NVARCHAR(500)` | |

### 6.2 DescriptionRules

Governs the generation of automated descriptive text for dashboard cards.

| Column | Type | Notes |
|---|---|---|
| `RuleID` | `INT IDENTITY` PK | |
| `RuleName` | `NVARCHAR(100)` NOT NULL | |
| `Dataset` | `NVARCHAR(100)` NOT NULL | Matches a `DataSetName` in VisualisationQueries |
| `Catery` | `NVARCHAR(50)` | Category (note: column name spelling as per source) |
| `ConditionsJSON` | `NVARCHAR(MAX)` NOT NULL | Trigger conditions |
| `DescriptionType` | `NVARCHAR(50)` | |
| `Priority` | `INT DEFAULT 50` | |
| `Severity` | `NVARCHAR(20)` | |
| `ExecutionOrder` | `INT` | |
| `DependsOnRuleID` | `INT` FK → `DescriptionRules.RuleID` | Chained rule dependency |
| `PassMetricsToNext` | `BIT DEFAULT 0` | |
| `ReferencesRuleIDs` | `NVARCHAR(500)` | Comma-separated referenced rule IDs |
| `ReferenceCondition` | `NVARCHAR(MAX)` | |
| `CalculatesScore` | `BIT DEFAULT 0` | |
| `ScoreFormulaJSON` | `NVARCHAR(MAX)` | |
| `GeneratesSuggestion` | `BIT DEFAULT 0` | |
| `SuggestionTemplateID` | `INT` | |
| `ThresholdsJSON` | `NVARCHAR(MAX)` | |
| `IsActive` | `BIT DEFAULT 1` | |
| `CreatedDate` | `DATETIME DEFAULT GETDATE()` | |
| `UpdatedDate` | `DATETIME DEFAULT GETDATE()` | |
| `Notes` | `NVARCHAR(500)` | |

### 6.3 DescriptionTemplates

Stores localised text templates used to render the generated descriptions.

| Column | Type | Notes |
|---|---|---|
| `TemplateID` | `INT IDENTITY` PK | |
| `TemplateName` | `NVARCHAR(100)` NOT NULL | |
| `Dataset` | `NVARCHAR(100)` NOT NULL | |
| `DescriptionType` | `NVARCHAR(50)` NOT NULL | |
| `TemplateText` | `NVARCHAR(MAX)` NOT NULL | Handlebars-style template with variable placeholders |
| `TemplateVariablesJSON` | `NVARCHAR(MAX)` | Variable definitions |
| `ConditionsJSON` | `NVARCHAR(MAX)` | When this template should be selected |
| `Scope` | `NVARCHAR(20) DEFAULT 'Both'` | CHECK: `'Both'`, `'Global'`, or `'Location'` |
| `Priority` | `INT DEFAULT 50` | |
| `Catery` | `NVARCHAR(50)` | Category |
| `Severity` | `NVARCHAR(20)` | |
| `IsActive` | `BIT DEFAULT 1` | |
| `IsDefault` | `BIT DEFAULT 0` | |
| `CreatedDate` | `DATETIME DEFAULT GETDATE()` | |
| `UpdatedDate` | `DATETIME DEFAULT GETDATE()` | |
| `CreatedBy` | `NVARCHAR(100)` | |
| `Notes` | `NVARCHAR(500)` | |

### 6.4 MetricDefinitions

Defines the metrics that can be referenced by `DescriptionRules` and `ActionInferenceRules`.

| Column | Type | Notes |
|---|---|---|
| `MetricID` | `INT IDENTITY` PK | |
| `MetricName` | `NVARCHAR(100)` NOT NULL UNIQUE | |
| `DisplayName` | `NVARCHAR(200)` | |
| `Description` | `NVARCHAR(500)` | |
| `Catery` | `NVARCHAR(50)` | |
| `SourceType` | `NVARCHAR(50)` | |
| `SourceSQL` | `NVARCHAR(MAX)` | SQL expression to compute the metric |
| `IsLocationSpecific` | `BIT DEFAULT 1` | |
| `AggregationType` | `NVARCHAR(50)` | SUM, AVG, etc. |
| `RequiresMetrics` | `NVARCHAR(500)` | Comma-separated prerequisite metric names |
| `CalculationFormula` | `NVARCHAR(MAX)` | Derived calculation |
| `DataType` | `NVARCHAR(20)` | |
| `UnitOfMeasure` | `NVARCHAR(50)` | |
| `ExampleValue` | `NVARCHAR(100)` | |
| `IsActive` | `BIT DEFAULT 1` | |
| `CreatedDate` | `DATETIME DEFAULT GETDATE()` | |
| `UpdatedDate` | `DATETIME DEFAULT GETDATE()` | |
| `Notes` | `NVARCHAR(500)` | |

---

## 7. End-to-end data flow summary

```
Data Sources (POS, Inventory, Survey)
        |
        | Integration trigger / staging
        v
[datavault].SAT_* / LNK_* / HUB_* tables
        |
        | PresentationControl query_sql (22 steps, Tier 1 then Tier 2)
        | - Recursive CTE hierarchy flattening for dimensions
        | - Sentinel join pattern for facts
        | - Window-function feature engineering for forecasting
        v
[presentation].D_* / F_* / CALENDAR / FORECAST_ACTUALS_BASE tables
        |
        | VisualisationQueries (109 records, 89 datasets)
        | - QueryTemplate / ExecutionQuery SQL
        | - BuildDynamicWhereClause injects @FilterClause
        v
Card-type stored procedures (15 types)
{SCHEMA}.[BarChartCard | LineChartCard | PieChartCard | ...]
called with (@StartDate, @EndDate, @LocationList, @DataSet, @Filters)
        |
        v
Front-end dashboard cards
```

---

## 8. Parent Organisation Reporting Layer

Parent organisations aggregate child org presentation data into parent-level tables using PresentationControl steps at tiers 100–102. See `docs/architecture-overview.md` §15 for the quorum gate and dynamic SQL builder details.

### 8.1 Parent Dimension Tables

**PD_ORGANISATION** — Lists child organisations of the parent.

| Column | Type | Notes |
|---|---|---|
| ORG_CODE | uniqueidentifier | Child org code (clustered PK) |
| ORG_NAME | nvarchar(255) | Child org name |
| ORG_PREFIX | nvarchar(255) | Child org prefix |
| DATABASE_NAME | nvarchar(128) | Child database name |
| IS_ACTIVE | bit | Active flag |
| CREATED_DATE | datetime2(7) | Org creation date |

**PD_LOCATION** — UNION ALL of child D_LOCATION tables with org identifier prepended. 40 columns: ORG_CODE + ORG_NAME + all 38 D_LOCATION columns (BOTTOM_*, MIDDLE_1_*, TOP_*, HIERARCHY_PATH, TOTAL_LEVELS). Clustered on (ORG_CODE, BOTTOM_HUB_ID).

### 8.2 Parent Fact Tables

**PF_REVENUE_DAY** — Daily revenue aggregated from child F_LINEITEM_15MIN (15-min → day grain).

| Column | Type | Source |
|---|---|---|
| ORG_CODE | uniqueidentifier | Child org code |
| ORG_NAME | nvarchar(255) | Child org name |
| LOCATION_HUB_ID | binary(32) | Location key |
| CHANNEL_HUB_ID | binary(32) | Channel key |
| LI_TYPE | nvarchar(255) | Line item type (PROD, TAX, etc.) |
| ORDER_DATE | datetime2(7) | Date (day grain) |
| GROSS_VALUE | decimal(38,10) | SUM of child gross |
| TAX_VALUE | decimal(38,10) | SUM of child tax |
| NET_VALUE | decimal(38,10) | SUM of child net |
| ORDER_COUNT | decimal(38,10) | SUM of child orders |
| QUANTITY | decimal(38,10) | SUM of child quantity |

**PF_PROFIT_DAY** — Daily profit aggregated from child F_PRODUCT_MARGIN_DAY.

| Column | Type | Source |
|---|---|---|
| ORG_CODE, ORG_NAME | identifiers | Child org |
| LOCATION_HUB_ID | binary(32) | Location key |
| CHANNEL_HUB_ID | binary(32) | Channel key |
| ORDER_DATE | datetime2(7) | Date (day grain) |
| NET_VALUE | decimal(38,10) | SUM net value |
| QUANTITY | decimal(38,10) | SUM quantity |
| PROFIT | decimal(38,10) | SUM profit |
| PROFIT_LESS_DISCOUNT | decimal(38,10) | SUM profit less discount |
| DISCOUNT_IMPACT | decimal(38,10) | PROFIT - PROFIT_LESS_DISCOUNT |

**PF_FOODCOST_DAY** — Daily food cost aggregated from child F_INV_SALES_DAY.

| Column | Type | Source |
|---|---|---|
| ORG_CODE, ORG_NAME | identifiers | Child org |
| LOCATION_HUB_ID | binary(32) | Location key |
| INV_DATE | datetime2(7) | Inventory date |
| TOTAL_UOM_COST | decimal(38,6) | SUM UOM_COST |
| TOTAL_RECIPE_COST | decimal(38,6) | SUM SALES_RECIPE_COST |
| NET_SALES | decimal(38,6) | SUM NET_SALES |

**PF_INVENTORY_EFFICIENCY_DAY** — Daily inventory efficiency from child F_INV_COUNTS_DAY (cost-weighted).

| Column | Type | Source |
|---|---|---|
| ORG_CODE, ORG_NAME | identifiers | Child org |
| LOCATION_HUB_ID | binary(32) | Location key |
| COUNT_DATE | datetime2(7) | Count date |
| INVENTORY_VALUE | decimal(38,6) | SUM(ACTUAL_COUNT * UOM_COST) |
| THEO_USAGE_COST | decimal(38,6) | SUM(THEO_USAGE * UOM_COST) |
| ACTUAL_USAGE_COST | decimal(38,6) | SUM(ACTUAL_USAGE * UOM_COST) |
| VARIANCE_COST | decimal(38,6) | SUM(VARIANCE * UOM_COST) |
| WASTE_COST | decimal(38,6) | SUM(WASTE_QTY * UOM_COST) |
| TRANSFER_COST | decimal(38,6) | SUM(TRANSFER_QTY * UOM_COST) |

**PF_GROWTH_PERIOD** — Period-over-period growth derived from PF_REVENUE_DAY (Tier 102).

| Column | Type | Notes |
|---|---|---|
| ORG_CODE, ORG_NAME | identifiers | Child org |
| LOCATION_HUB_ID | binary(32) | NULL = org-wide aggregate |
| PERIOD_TYPE | varchar(10) | WEEK, MONTH, or QUARTER |
| PERIOD_START, PERIOD_END | date | Period boundaries |
| NET_REVENUE | decimal(38,10) | Current period revenue |
| ORDER_COUNT | decimal(38,10) | Current period orders |
| PREV_PERIOD_REVENUE | decimal(38,10) | Previous sequential period |
| PREV_YEAR_REVENUE | decimal(38,10) | Same period last year |
| REVENUE_GROWTH_PCT | decimal(10,4) | Period-over-period % change |
| REVENUE_GROWTH_YOY_PCT | decimal(10,4) | Year-over-year % change |
| AVG_ORDER_VALUE | decimal(38,10) | Revenue / order count |

### 8.3 Parent Visualisation Queries

4 initial parent dashboard cards:

| DataSetName | Card Type | Source Table | Description |
|---|---|---|---|
| ParentNetSales | SingleKPICard | PF_REVENUE_DAY | Consolidated net sales with period change |
| ParentOrgRevenue | StackedBarChartCard | PF_REVENUE_DAY | Net sales per org as stacked bars by week |
| ParentOrgRevenueTrend | MultiLineChartCard | PF_REVENUE_DAY | Revenue over time with org as series |
| ParentLocationRankings | CustomGroupedDataGrid | PF_REVENUE_DAY + PD_LOCATION | All locations ranked by net sales |

All parent vis queries include an `Organisations` filter (on `PD_ORGANISATION.ORG_NAME`) in addition to standard Locations and DateRange filters.

---

## 9. File reference index

| File | Lines | Primary purpose |
|---|---|---|
| `6_DeployPresentationTables.sql` | 255 | Deployment procedure for presentation table DDL |
| `8_PresentationTables.sql` | 1,625 | 24 presentation table DDL definitions inserted into `core.PresentationTables` |
| `8_PresentationControl.sql` | 5,206 | 22 ETL build steps inserted into `core.PresentationControl` |
| `8_VisualisationQueries.sql` | 21,520 | 109 visualisation query records inserted into `core.core.VisualisationQueries` |
| `8_Deployment_Objects_Records.sql` | ~1,800 | 46 deployment objects including 16 card procedures, utility functions, and control tables |
| `7_Dynamic Suggestion Tables.sql` | 234 | 4 AI/suggestion support tables: `ActionInferenceRules`, `DescriptionRules`, `DescriptionTemplates`, `MetricDefinitions` |
