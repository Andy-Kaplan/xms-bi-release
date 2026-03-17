# XMS BI Platform - Integrations Reference

**Document Version:** 1.0
**Generated:** 2026-03-01
**Source Files:** `C:/threerocks_data/XMS BI/Release/`

This document is a comprehensive technical reference for all five integration implementations deployed in the XMS BI platform. Each section covers every file in the integration subfolder, the complete list of Data Landing (DL) tables, staging pipeline steps, Data Vault entity mappings, and notable implementation patterns. All details are sourced directly from the SQL files.

---

## Table of Contents

1. [Platform Overview](#platform-overview)
2. [NCRAloha (POS Integration)](#ncr-aloha-pos-integration)
3. [MarketMan (Inventory Integration)](#marketman-inventory-integration)
4. [Growyze (Inventory Integration)](#growyze-inventory-integration)
5. [SurveyHero (Survey Integration)](#surveyhero-survey-integration)
6. [TROAP (Three Rocks Own Ordering Platform)](#troap-pos-integration)
7. [Cross-Integration Patterns](#cross-integration-patterns)

---

## Platform Overview

The XMS BI platform ingests data from external APIs and internal databases into a centralised Data Vault 2.0 model. Each integration follows a standardised five-file deployment pattern (with some variations):

| File Suffix | Purpose |
|---|---|
| `_INIT.sql` | Registers the integration in `[core].[Integrations]`, stores the API endpoint configuration as JSON, and sets the `IntegrationType` flag. |
| `_DDL.sql` | Upserts DDL strings into `[GlobalParameters]` under `Category = 'STAGE_DDL'`. Each DL table definition is stored as a parameter and executed at runtime to (re)create the raw landing table. |
| `_Staging.sql` | Upserts staging control records into `[StagingControl]`. Each record defines a staging step with its SQL query, tier number, staging table name, and dependency metadata. |
| `_Mapping.sql` | Upserts entity mapping records into `[EntityMappings]`. Each record maps a staging table to a Data Vault hub or link entity, specifying column hashes and Type 2 SCD tracking columns. |
| `_Final.sql` | Executes `[core].[UploadEntityMappings]` to activate/apply all entity mappings for the integration schema. |

All DL tables include two mandatory system columns:

- `[LOADTS_UTC] datetime2` — UTC timestamp when the row was loaded into the DL table.
- `[INT_FETCH_DATE] datetime2` — The date context (business date or fetch date) used during API extraction.

---

## NCR Aloha (POS Integration)

**Integration Name:** `NCRAloha001`
**Display Name:** NCR Aloha Version 1
**IntegrationType:** `POS`
**Schema:** `int_ncraloha001`
**Source:** NCR Aloha REST API v3 (`https://api.ncr.com/rt`)
**Source Folder:** `C:/threerocks_data/XMS BI/Release/NCRAloha/`

### Files

> **Note:** Line counts are approximate snapshots and may not reflect the current file state.

| File | Lines | Description |
|---|---|---|
| `NCRAloha001_INIT.sql` | ~245 | Registers integration; stores full endpoint JSON with `endpoints`, `pagination`, and `unravel_properties` config; sets `IntegrationType = 'POS'`. |
| `NCRAloha001_DDL.sql` | ~1,021 | DDL definitions for 21 DL tables. Declared in `GlobalParameters` under `Category = 'STAGE_DDL'`. |
| `NCRAloha001_Staging.sql` | ~2,680 | 27 staging control steps across three tiers, producing `stage.NCR_*` tables. |
| `NCRAloha001_Mapping.sql` | ~990 | 34 entity mapping definitions targeting Data Vault hubs and links. |
| `NCRAloha001_Final.sql` | 12 | Executes `[core].[UploadEntityMappings] @intSchema = N'int_ncraloha001'` to activate all mappings. |

### API Endpoint Configuration

The INIT file stores the endpoint configuration as a JSON blob. NCR Aloha exposes five logical endpoints:

| Endpoint Key | API Path | Description | Pagination |
|---|---|---|---|
| `store` | *(base URL only)* | Store/location list; renames `pulseId` → `storeId` | No |
| `sales` | `sales` | Daily sales summary; explodes `links` array | No |
| `sales_check` | `sales/check` | Check-level sales; explodes and unnests `checks` | No |
| `sales_stream` | `sales/stream` | Full transaction stream; explodes `checks`, then unnests 9 sub-arrays | Yes (`marker` / `moreDataImmediatelyAvailable`) |
| `labor` | `labor` | Labor shifts; explodes `shifts`, then unnests `payRates` and `breaks` | Yes (`marker` / `moreDataImmediatelyAvailable`) |

The pagination mechanism uses a cursor-style `marker` field: the API returns `moreDataImmediatelyAvailable = true` when additional pages exist, and the next request passes the `marker` value to advance.

The `sales_stream` endpoint is the most complex, using `header_identifiers` of `(storeId, dob, id → checks_id)` to propagate parent-check context down into 9 child arrays (clears, comps, events, items, payments, promos, responsibleEmployees, surcharges, voids), each of which can have further nested `linkedItems` arrays.

### DL Tables (21 total)

Source: `NCRAloha001_DDL.sql`, lines 6–1021. All columns are `nvarchar(max)` unless noted.

#### Labor Group

| Table | Key Columns |
|---|---|
| `DL_LABOR` | `storeId`, `dob`, `marker`, `moreDataImmediatelyAvailable`, `link`, `id`, `manager`, `reportable`, `state`, `startDate`, `endDate`, `totalPay`, `declaredTips`, `creditCardTips`, `employee_id`, `employee_name`, `job_id`, `job_label` |
| `DL_LABOR_PAYRATES` | `storeId`, `dob`, `shifts_id`, `rate`, `appliedAfter`, `time` |

#### Sales Summary Group

| Table | Key Columns |
|---|---|
| `DL_SALES` | `storeId`, `dob`, `netSales`, `giftCardSales`, `payments`, `tips`, `gratuities`, `promos`, `comps`, `voids`, `checkCount`, `guestCount`, `serviceType`, `links` |
| `DL_SALES_CHECK` | `storeId`, `dob`, `id`, `printableId`, `marker`, `total`, `netAmount`, `isClosed`, `isEmpty`, `isTraining`, `link` |

#### Sales Stream Group (check-level detail)

| Table | Key Columns |
|---|---|
| `DL_SALES_STREAM` | `storeId`, `dob`, `marker`, `moreDataImmediatelyAvailable`, `link`, `terminalId`, `grossAmount`, `grandAmount`, `id`, `printedCheckId`, `netAmount`, `total`, `isRefund`, `training`, `closed`, `isTaxExemptApplied`, `takeOutOrderId`, `groupInfo_id`, `groupInfo_label`, `guestCounting_guests`, `guestCounting_mode`, `revenueCenter_id`, `revenueCenter_label`, `period_id`, `period_label` |
| `DL_SALES_STREAM_CLEARS` | `storeId`, `dob`, `checks_id`, `type`, `id`, `typeId`, `label`, `amount`, `createdOn`, `responsibleEmployees_employee_id`, `responsibleEmployees_employee_name` |
| `DL_SALES_STREAM_CLEARS_LINKEDITEMS` | `storeId`, `dob`, `checks_id`, `clears_id`, `id`, `amount` |
| `DL_SALES_STREAM_COMPS` | `storeId`, `dob`, `checks_id`, `type`, `note`, `id`, `typeId`, `label`, `amount`, `createdOn`, `responsibleEmployees_employee_id`, `responsibleEmployees_employee_name`, `responsibleEmployees_manager_id`, `responsibleEmployees_manager_name` |
| `DL_SALES_STREAM_COMPS_LINKEDITEMS` | `storeId`, `dob`, `checks_id`, `comps_id`, `id`, `amount` |
| `DL_SALES_STREAM_EVENTS` | `storeId`, `dob`, `checks_id`, `customEventLabel`, `time`, `type` |
| `DL_SALES_STREAM_ITEMS` | `storeId`, `dob`, `checks_id`, `responsibleEmployeeId`, `netAmount`, `originalPrice`, `quantity`, `seat`, `parentItemId`, `revenue`, `processedInKitchen`, `giftCard`, `id`, `typeId`, `label`, `amount`, `createdOn`, `modifierInfo_type`, `orderMode_id`, `orderMode_label`, `period_id`, `period_label`, `modifierInfo_id_id`, `modifierInfo_id_label`, `responsibleEmployees_employee_id`, `responsibleEmployees_employee_name` |
| `DL_SALES_STREAM_ITEMS_CATEGORIES` | `storeId`, `dob`, `checks_id`, `items_id`, `id`, `name`, `type` |
| `DL_SALES_STREAM_PAYMENTS` | `storeId`, `dob`, `checks_id`, `tip`, `type`, `card`, `overpayment`, `id`, `typeId`, `label`, `amount`, `createdOn`, `responsibleEmployees_employee_id`, `responsibleEmployees_employee_name`, `authorizationInfo_authorizationCode`, `authorizationInfo_authAmount`, `authorizationInfo_refId` |
| `DL_SALES_STREAM_PROMOS` | `storeId`, `dob`, `checks_id`, `discount`, `type`, `id`, `typeId`, `label`, `amount`, `createdOn`, `responsibleEmployees_employee_id`, `responsibleEmployees_employee_name` |
| `DL_SALES_STREAM_PROMOS_LINKEDITEMS` | `storeId`, `dob`, `checks_id`, `promos_id`, `id`, `amount` |
| `DL_SALES_STREAM_RESPONSIBLEEMPLOYEES` | `storeId`, `dob`, `checks_id`, `shiftId`, `isTippableEmployee`, `roleId`, `roleName`, `id`, `name`, `time` |
| `DL_SALES_STREAM_SURCHARGES` | `storeId`, `dob`, `checks_id`, `rate`, `type`, `accounting`, `taxableSales`, `id`, `typeId`, `label`, `amount`, `createdOn` |
| `DL_SALES_STREAM_SURCHARGES_LINKEDITEMS` | `storeId`, `dob`, `checks_id`, `surcharges_id`, `linkedItems` |
| `DL_SALES_STREAM_VOIDS` | `storeId`, `dob`, `checks_id`, `type`, `id`, `typeId`, `label`, `amount`, `createdOn`, `responsibleEmployees_employee_id`, `responsibleEmployees_employee_name`, `responsibleEmployees_manager_id`, `responsibleEmployees_manager_name` |
| `DL_SALES_STREAM_VOIDS_LINKEDITEMS` | `storeId`, `dob`, `checks_id`, `voids_id`, `id`, `amount` |

#### Reference Group

| Table | Key Columns |
|---|---|
| `DL_STORE` | `storeId`, `insightId`, `name`, `link` |

### Staging Steps (27 total)

Source: `NCRAloha001_Staging.sql`. Each step drops and recreates a `stage.NCR_*` table using `SELECT * INTO`.

#### Tier 1 — Base Staging (12 steps)

These steps read directly from the DL tables and produce normalised staging tables.

| Step Name | Staging Table | Source DL Table(s) | Description |
|---|---|---|---|
| Channel and Cust Order Link | `NCR_CHANNEL_LINK` | `DL_SALES_STREAM` | Derives channel from `takeOutOrderId` / `revenueCenter_label`; produces `HEADER_SRC_KEY`, `CHANNEL`, `LEVE_NAME`, `BOTTOM_LEVEL` |
| Deal | `NCR_DEAL` | `DL_SALES_STREAM_PROMOS` | Builds deal hierarchy from item `typeId`; uses `ROW_NUMBER()` to pick latest `dob` per item |
| Discount | `NCR_DISC` | `DL_SALES_STREAM_COMPS` | Normalises promotional discount line items |
| Employee Timecard | `NCR_EMP_TIME` | `DL_LABOR` | Produces timecard entries from shift records |
| Line Item Detail | `NCR_LINE_ITEM_DETAIL` | `DL_SALES_STREAM_ITEMS`, `DL_SALES_STREAM` | Core staging table; uses a UNION across multiple DL tables to produce multiple `LINEITEM_TYPE` values — at minimum: `MOD`, `PROD`, `TAX`, `SVC`, `DEAL`, `DISCOUNT`, `TENDER` (7 distinct types). Uses window functions (`SUM OVER PARTITION BY`) to compute order-level totals (net sales, tax, gross sales, service charge, item count, guest count); derives `PAYMENT_STATUS` as `PAID` / `PARTIAL` / `NULL` |
| Location | `NCR_LOCATION` | `DL_STORE` | Maps store IDs to location hub keys |
| Modifications | `NCR_MODS` | `DL_SALES_STREAM_ITEMS` | Filters item rows where `modifierInfo_type IS NOT NULL` |
| Occasion | `NCR_OCCASSION` | `DL_SALES_STREAM_ITEMS` | Derives occasion from `orderMode_id` / `orderMode_label` |
| Product | `NCR_PROD` | `DL_SALES_STREAM_ITEMS` | Filters non-modifier item rows; builds product hierarchy |
| Revenue Center | `NCR_REVC` | `DL_SALES_STREAM` | Extracts `revenueCenter_id` / `revenueCenter_label` |
| Service Charge | `NCR_SVC` | `DL_SALES_STREAM_SURCHARGES` | Normalises surcharge line items |
| Tax | `NCR_TAX` | `DL_SALES_STREAM_ITEMS`, `DL_SALES_STREAM_ITEMS_CATEGORIES` | Extracts category-type tax entries; joins both tables |

#### Tier 2 — Link Staging (14 steps)

These steps join Tier 1 staging tables to produce link/relationship tables.

| Step Name | Staging Table | Description |
|---|---|---|
| Comp to Line Item | `COMP_LI_LNK` | Links comp records to their affected line items |
| Deal to Line Item | `DEAL_LI_LNK` | Links deal nodes to line items |
| Deals & Line Item to Line Item | `NCR_DEAL_LI_LI` | Self-referencing deal hierarchy link |
| Discount & Line Item to Line Item | `NCR_DISC_LI_LI` | Links discount adjustments to line items |
| Discount to Line Item | `DISC_LI_LNK` | Direct discount-to-line-item association |
| Mod to Line Item | `MOD_LI_LNK` | Links modifier items to parent items |
| Occasion to Line Item | `OCC_LI_LNK` | Links occasion context to line items |
| Product to Line Item | `PROD_LI_LNK` | Links product records to line items |
| Product to Location and Occasion | `LOC_OCC_PROD_LNK` | Ternary link: product + location + occasion |
| Service Charge & Line Item to Line Item | `NCR_SVC_LI_LI` | Service charge with linked item context |
| Service Charge to Line Item | `SVC_LI_LNK` | Direct service charge association |
| Tax & Line Item to Line Item | `NCR_TAX_LI_LI` | Tax with linked item context |
| Tax to Line Item | `TAX_LI_LNK` | Direct tax-to-line-item association |
| Tender to Line Item | `TEND_LI_LINK` | Links payment tender records to checks |

#### Tier 3 — Self-Link (1 step)

| Step Name | Staging Table | Description |
|---|---|---|
| Line Item to Line Item | `LI_LI_LINK` | Captures parent-child relationships between line items (e.g., modifier-to-product) |

### Entity Mappings (34 total)

Source: `NCRAloha001_Mapping.sql`. The `hash: 1` flag on a source column indicates it is used to compute the hub's binary hash key (`HUB_ID`). Entities without a `_` in the name are hubs; entities with a `_` separating two domain names are links.

**Hubs (15):**

| Entity | Source Table | Hub Key Column | Description |
|---|---|---|---|
| `CHANNEL` | `NCR_CHANNEL_LINK` | `CHANNEL` | Sales channel dimension (e.g., Pos, delivery platform name) |
| `CUSTORDER` | `NCR_LINE_ITEM_DETAIL` | `HEADER_ID` | Customer order / check header |
| `DEAL` | `NCR_DEAL` | `ITEM_SRC_KEY` | Deal/combo product hierarchy node |
| `DISCOUNT` | `NCR_DISC` | *(from discount staging)* | Discount/promo type |
| `EMPLOYEE` | `NCR_EMP_TIME` | `EMP_SRC_KEY` | Employee record |
| `JOB` | *(from labor staging)* | *(job_id)* | Job/role classification |
| `LINEITEM` | `NCR_LINE_ITEM_DETAIL` | `SRC_KEY` | Individual line item |
| `LOCATION` | `NCR_LINE_ITEM_DETAIL` | `LOCATION_ID` | Store/location |
| `MOD` | *(from mod staging)* | *(modifier key)* | Menu modifier |
| `OCCASION` | *(from occasion staging)* | *(period_id)* | Service period/meal occasion |
| `PRODUCT` | *(from product staging)* | *(typeId)* | Menu product |
| `REVCENTER` | `NCR_LINE_ITEM_DETAIL` | `REVENUE_CENTER_SRC_KEY` | Revenue centre |
| `SVCCHARGE` | *(from svc charge staging)* | *(surcharge id)* | Service charge type |
| `TAX` | `NCR_TAX` | `ITEM_SRC_KEY` | Tax category |
| `TIMECARD` | `NCR_EMP_TIME` | `TIMECARD_SRC_KEY` | Employee shift timecard |

**Links (19):**

| Entity | Source Table | Left Key Column | Right Key Column |
|---|---|---|---|
| `CHANNEL_CUSTORDER` | `NCR_CHANNEL_LINK` | `CHANNEL` (→ CHANNEL_HUB_ID) | `HEADER_SRC_KEY` (→ CUSTORDER_HUB_ID) |
| `COMP_LINEITEM` | `COMP_LI_LNK` | `SRC_KEY` (→ LINEITEM_HUB_ID) | `ITEM_SRC_KEY` (→ COMP_HUB_ID) |
| `CUSTORDER_EMPLOYEE` | `NCR_LINE_ITEM_DETAIL` | `HEADER_ID` (→ CUSTORDER_HUB_ID) | `EMPLOYEE_SRC_KEY` (→ EMPLOYEE_HUB_ID) |
| `CUSTORDER_LINEITEM` | `NCR_LINE_ITEM_DETAIL` | `SRC_KEY` (→ LINEITEM_HUB_ID) | `HEADER_ID` (→ CUSTORDER_HUB_ID) |
| `CUSTORDER_LOCATION` | `NCR_LINE_ITEM_DETAIL` | `HEADER_ID` (→ CUSTORDER_HUB_ID) | `LOCATION_ID` (→ LOCATION_HUB_ID) |
| `CUSTORDER_OCCASION` | `NCR_LINE_ITEM_DETAIL` | `HEADER_ID` (→ CUSTORDER_HUB_ID) | `OCCASSION_SRC_KEY` (→ OCCASION_HUB_ID) |
| `CUSTORDER_REVCENTER` | `NCR_LINE_ITEM_DETAIL` | `HEADER_ID` (→ CUSTORDER_HUB_ID) | `REVENUE_CENTER_SRC_KEY` (→ REVCENTER_HUB_ID) |
| `DEAL_LINEITEM` | `DEAL_LI_LNK` | *(deal key)* | *(line item key)* |
| `DISCOUNT_LINEITEM` | `DISC_LI_LNK` | *(discount key)* | *(line item key)* |
| `EMPLOYEE_JOB_TIMECARD` | `NCR_EMP_TIME` | *(employee + job)* | *(timecard key)* |
| `EMPLOYEE_LINEITEM` | `NCR_LINE_ITEM_DETAIL` | *(employee key)* | *(line item key)* |
| `LINEITEM_LINEITEM` | `LI_LI_LINK` | *(parent line item)* | *(child line item)* |
| `LINEITEM_MOD` | `MOD_LI_LNK` | *(line item key)* | *(modifier key)* |
| `LINEITEM_OCCASION` | `OCC_LI_LNK` | *(line item key)* | *(occasion key)* |
| `LINEITEM_PRODUCT` | `PROD_LI_LNK` | *(line item key)* | *(product key)* |
| `LINEITEM_SVCCHARGE` | `SVC_LI_LNK` | *(line item key)* | *(service charge key)* |
| `LINEITEM_TAX` | `TAX_LI_LNK` | *(line item key)* | *(tax key)* |
| `LINEITEM_TENDER` | `TEND_LI_LINK` | *(line item key)* | *(tender key)* |
| `LOCATION_OCCASION_PRODUCT` | `LOC_OCC_PROD_LNK` | `LOCATION_ID` | `OCC_ID` + `PRODUCT_ID` (ternary) |

### Notable Patterns

**Cursor-based pagination:** The `sales_stream` and `labor` endpoints paginate using a `marker` value. The extraction loop queries while `moreDataImmediatelyAvailable = 'true'` and passes the `marker` value to the next request. This is declared in the INIT JSON under `"pagination": {"pagination_value_key": "marker", "pagination_flag_key": "moreDataImmediatelyAvailable"}`.

**Window function aggregation in staging:** The `Line Item Detail` step (Tier 1) is the central staging table for NCR Aloha. It uses multiple `SUM(...) OVER (PARTITION BY HEADER_ID)` window functions to compute order-level totals from item-level rows — avoiding the need to separately aggregate before joining:

```sql
-- NCRAloha001_Staging.sql, line 400 (simplified)
SUM(ISNULL(SUB.NET_VALUE,0)) OVER(PARTITION BY SUB.HEADER_ID) AS NET_SALES
,SUM(ISNULL(SUB.TAX_VALUE,0)) OVER(PARTITION BY SUB.HEADER_ID) AS TAX_TOTAL
,SUM(ISNULL(SUB.QUANTITY,0)) OVER(PARTITION BY SUB.HEADER_ID) AS ITEM_COUNT
```

**LINEITEM_TYPE derivation:** The `NCR_LINE_ITEM_DETAIL` staging step uses a UNION across multiple DL tables to produce at least 7 distinct `LINEITEM_TYPE` values: `MOD`, `PROD`, `TAX`, `SVC`, `DEAL`, `DISCOUNT`, and `TENDER`. Within the items branch specifically, rows from `DL_SALES_STREAM_ITEMS` are classified as `MOD` (modifier) when `modifierInfo_type IS NOT NULL`, and `PROD` (product) otherwise. The type value is concatenated into the composite `SRC_KEY` so that line items of different types on the same check produce distinct DV keys.

**Channel derivation:** The channel dimension is derived from a `CASE` expression in Tier 1 staging:

```sql
-- NCRAloha001_Staging.sql, line 26
CASE WHEN [takeOutOrderId] IS NULL THEN 'Pos'
     ELSE [revenueCenter_Label]
END AS CHANNEL
```

Orders with no takeout order ID are attributed to the `Pos` channel; delivery orders use the revenue centre label as the channel name.

**Composite surrogate keys:** All source keys use `CONCAT_WS('-', ...)` to combine `storeId`, `dob`, and the record ID into a unique string, for example:

```sql
-- NCRAloha001_Staging.sql, line 426
CONCAT_WS('-', SI.[storeId], SI.[dob], SI.[checks_id], SI.[id]) AS SUB_SRC_KEY
```

---

## MarketMan (Inventory Integration)

**Integration Name:** `Marketman001`
**Display Name:** Market Man Version 1
**IntegrationType:** `INVENTORY`
**Schema:** `int_marketman001`
**Source:** MarketMan REST API v3 (`https://api.marketman.com`)
**Source Folder:** `C:/threerocks_data/XMS BI/Release/MarketMan/`

### Files

> **Note:** Line counts are approximate snapshots and may not reflect the current file state.

| File | Lines | Description |
|---|---|---|
| `MarketMan001_INIT.sql` | ~494 | Registers integration; stores endpoint JSON for 18 API endpoints; sets `IntegrationType = 'INVENTORY'`. |
| `MarketMan001_DDL.sql` | ~1,960 | DDL definitions for 34 DL tables under `[int_marketman001]`. |
| `MarketMan001_Staging.sql` | ~2,280 | 17 staging control steps (16 Tier 1, 1 Tier 2). |
| `MarketMan001_Mapping.sql` | ~640 | 22 entity mapping definitions. |
| `MarketMan_Final.sql` | 12 | Executes `[core].[UploadEntityMappings] @intSchema = N'int_marketman001'`. (Note: omits the version suffix `001` used by other integrations — does not follow the standard `{Name}001_Final.sql` naming convention.) |

### API Endpoint Configuration

All MarketMan endpoints use `POST` requests with a JSON body. The `BuyerGuid` field in the request body is replaced at runtime with the integration's configured account GUID (`replacement_id`). Date-ranged endpoints accept `DateTimeFromUTC` / `DateTimeToUTC` or `StartDateUTC` / `EndDateUTC` parameters.

| Endpoint Key | API Path | Description | Date Ranged |
|---|---|---|---|
| `store` | `buyers/partneraccounts/GetAuthorisedAccounts` | Authorised buyer accounts; renames `Guid` → `storeId`, `BuyerName` → `StoreName` | No |
| `orders_by_sentDate` | `buyers/orders/GetOrdersBySentDate` | Purchase orders with items and history log | Yes |
| `menu_profitability` | `buyers/inventory/GetMenuProfitability` | Menu item profitability with cost data | Yes |
| `categories` | `buyers/categories/GetCategories` | Inventory item categories | No |
| `inventory_items` | `buyers/inventory/GetInventoryItems` | Inventory items with purchase sub-items; includes deleted (`GetDeleted: True`) | No |
| `inventory_preps` | `buyers/inventory/GetPreps` | Prep recipes with sub-items; includes deleted | No |
| `menu_items` | `buyers/inventory/GetMenuItems` | Menu items with location sync info and sub-items; includes deleted | No |
| `vendors` | `buyers/items/GetVendors` | Supplier/vendor list | No |
| `tax_levels` | `buyers/Taxes/GetTaxLevels` | Tax level definitions | No |
| `transfers` | `buyers/inventory/GetTransfers` | Stock transfer events with line items | Yes |
| `waste_events` | `buyers/inventory/GetWasteEvents` | Waste recording events with line items | Yes |
| `inventory_counts` | `buyers/inventory/GetInventoryCounts` | Stock count events with lines and count definition details | Yes |
| `uom_types` | `buyers/inventory/GetUOMTypes` | Unit of measure type definitions | No |
| `production_events` | `buyers/inventory/GetProductionEventsByDate` | Production/prep event records with produced items | Yes |
| `sales_by_date` | `buyers/sales/GetSalesByDates` | Sales summary records with category breakdowns | Yes |
| `docs_by_date` | `buyers/docs/GetDocsByDocDate` | Document records (invoices/credit notes) with items and history | Yes |
| `buyer_users` | `buyers/users/GetBuyerUsers` | Buyer user accounts | No |
| `actual_vs_theo` | `buyers/inventory/GetActualTheoDataByBuyer` | Actual vs theoretical usage with category totals | Yes |

### DL Tables (34 total)

Source: `MarketMan001_DDL.sql`, lines 6–1960.

#### Actual vs Theoretical Usage

| Table | Description |
|---|---|
| `DL_ACTUAL_VS_THEO` | Header record; `IsSuccess`, `ErrorMessage`, `ErrorCode`, `RequestID`, `storeId` |
| `DL_ACTUAL_VS_THEO_ACTUALTHEOCATEGORIESTOTALSROWS` | Category-level totals: `COGSCategory`, `COGSCategoryID`, `CategorySales`, `ActualUsage`, `ActualUsagePercent`, `ActualGrossProfit`, `ActualGPPercent`, `TheoreticalUsage`, `TheoreticalUsagePercent` |
| `DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS` | Item-level detail rows within the A vs T report |

#### Buyer Users

| Table | Description |
|---|---|
| `DL_BUYER_USERS` | User accounts: `ID`, `Name`, `Email`, `Role` fields |

#### Categories

| Table | Description |
|---|---|
| `DL_CATEGORIES` | Inventory item categories: `ID`, `Name`, `ParentID` |

#### Documents (Invoices/Credit Notes)

| Table | Description |
|---|---|
| `DL_DOCS_BY_DATE` | Document header: `DocNumber`, `DocDate`, `DocType`, `TotalAmount`, `storeId` |
| `DL_DOCS_BY_DATE_HISTORYLOG` | Status history log entries for each document |
| `DL_DOCS_BY_DATE_ITEMS` | Line items within each document: `CatalogItemID`, `Quantity`, `UnitPrice` |

#### Inventory Counts

| Table | Description |
|---|---|
| `DL_INVENTORY_COUNTS` | Count event header: `ID`, `CountDate`, `Status`, `storeId` |
| `DL_INVENTORY_COUNTS_LINES` | Count line items: `LineID`, `ItemID`, `CountedQuantity`, `UOM` |
| `DL_INVENTORY_COUNTS_LINES_COUNTDEFDETAILS` | Count definition details per line: `CountDefID`, `quantity` breakdowns |

#### Inventory Items (Master Data)

| Table | Description |
|---|---|
| `DL_INVENTORY_ITEMS` | Master inventory item: `ID`, `Name`, `CategoryID`, `UOM`, `ParLevel`, `IsDeleted` |
| `DL_INVENTORY_ITEMS_PURCHASEITEMS` | Vendor purchase configurations per item: `ProductCode`, `VendorGuid`, `PackSize`, `Price` |

#### Inventory Preps

| Table | Description |
|---|---|
| `DL_INVENTORY_PREPS` | Prep recipe header: `ID`, `Name`, `Yield`, `UOM` |
| `DL_INVENTORY_PREPS_SUBITEMS` | Recipe sub-ingredients: `ItemID`, `Quantity`, `UOM` |

#### Menu Items

| Table | Description |
|---|---|
| `DL_MENU_ITEMS` | Menu item definition: `ID`, `Name`, `PosCode`, `Price`, `RecipeIngredientsCost` |
| `DL_MENU_ITEMS_LOCATIONSYNCINFOS` | Location-specific sync metadata per menu item: `TypeID`, location flags |
| `DL_MENU_ITEMS_SUBITEMS` | Menu item sub-items/ingredients: `ItemID`, `Quantity` |

#### Menu Profitability

| Table | Description |
|---|---|
| `DL_MENU_PROFITABILITY` | Menu profitability snapshot per item: `ID`, `Name`, `SalesAmount`, `CostAmount`, `Margin` |

#### Orders

| Table | Description |
|---|---|
| `DL_ORDERS_BY_SENTDATE` | Purchase order header: `OrderNumber`, `SupplierGuid`, `OrderDate`, `Status`, `storeId` |
| `DL_ORDERS_BY_SENTDATE_HISTORYLOG` | Order status history log entries |
| `DL_ORDERS_BY_SENTDATE_ITEMS` | Order line items: `CatalogItemID`, `Quantity`, `UnitPrice`, `PackSize` |

#### Production Events

| Table | Description |
|---|---|
| `DL_PRODUCTION_EVENTS` | Production event header: `EventID`, `EventDate`, `Notes`, `storeId` |
| `DL_PRODUCTION_EVENTS_PRODUCTIONITEMS` | Items produced in the event: `ItemID`, `Quantity`, `UOM` |

#### Sales

| Table | Description |
|---|---|
| `DL_SALES_BY_DATE` | Sales summary record: `SaleSummaryID`, `SaleDate`, `TotalSales`, `storeId` |
| `DL_SALES_BY_DATE_CATEGORYSUMMARIES` | Category-level sales breakdown: `CategoryName`, `Sales`, `Quantity` |

#### Reference

| Table | Description |
|---|---|
| `DL_STORE` | Store reference: `storeId`, `StoreName` |
| `DL_TAX_LEVELS` | Tax level definitions: `ID`, `Name`, `Rate` |
| `DL_UOM_TYPES` | Unit of measure types: `ID`, `Name`, `BaseUnitID` |
| `DL_VENDORS` | Vendor/supplier master: `Guid`, `Name`, `ContactName`, `Email` |

#### Transfers

| Table | Description |
|---|---|
| `DL_TRANSFERS` | Transfer event header: `ID`, `TransferDate`, `FromStore`, `ToStore`, `storeId` |
| `DL_TRANSFERS_LINES` | Transfer line items: `LineID`, `ItemID`, `Quantity`, `UOM` |

#### Waste Events

| Table | Description |
|---|---|
| `DL_WASTE_EVENTS` | Waste event header: `ID`, `WasteDate`, `Reason`, `storeId` |
| `DL_WASTE_EVENTS_LINES` | Waste line items: `LineID`, `ItemID`, `Quantity`, `UOM`, `Cost` |

### Staging Steps (17 total)

Source: `MarketMan001_Staging.sql`.

#### Tier 1 — Base Staging (16 steps)

> **Note:** Step names are stored exactly as shown — case matters when querying StagingControl.

| Step Name | Staging Table | Primary Source DL Table(s) |
|---|---|---|
| Inventory Items | `MMAN_INVITEMS` | `DL_INVENTORY_ITEMS`, `DL_INVENTORY_ITEMS_PURCHASEITEMS` |
| Invoice Items | `MMAN_PRE_INVOICE` | `DL_DOCS_BY_DATE`, `DL_DOCS_BY_DATE_ITEMS` |
| Location | `MMAN_LOCATION` | `DL_STORE` |
| MMAN_PREP_RECIPES | `MMAN_PREP_RECIPES` | `DL_INVENTORY_PREPS`, `DL_INVENTORY_PREPS_SUBITEMS` |
| Order Items | `MMAN_PRE_ORDEREVENT` | `DL_ORDERS_BY_SENTDATE`, `DL_ORDERS_BY_SENTDATE_ITEMS` |
| Product Details | `MMAN_PRODUCT` | `DL_MENU_ITEMS`, `DL_MENU_ITEMS_LOCATIONSYNCINFOS` |
| production | `MMAN_PRE_PRODUCTION` | `DL_PRODUCTION_EVENTS`, `DL_PRODUCTION_EVENTS_PRODUCTIONITEMS` |
| Production Events | `MMAN_PROD_EVENTS` | `DL_PRODUCTION_EVENTS` |
| Report | `MMAN_REPORT` | `DL_ACTUAL_VS_THEO`, `DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS` |
| Sales | `MMAN_SALES` | `DL_SALES_BY_DATE` |
| Sales Line Item | `MMAN_LINEITEM` | `DL_SALES_BY_DATE`, `DL_SALES_BY_DATE_CATEGORYSUMMARIES` |
| Stock Count | `MMAN_PRE_STOCK_COUNT` | `DL_INVENTORY_COUNTS`, `DL_INVENTORY_COUNTS_LINES` |
| Stock Orders | `MMAN_STOCKORDER` | `DL_ORDERS_BY_SENTDATE` |
| Transfers | `MMAN_TRANSFERS` | `DL_TRANSFERS`, `DL_TRANSFERS_LINES` |
| vendors | `MMAN_VENDORS` | `DL_VENDORS` |
| Waste Events | `MMAN_WASTE_EVENTS` | `DL_WASTE_EVENTS`, `DL_WASTE_EVENTS_LINES` |

#### Tier 2 — Derived Staging (1 step)

| Step Name | Staging Table | Description |
|---|---|---|
| Stock Event | `MMAN_STOCKEVENT` | Consolidates orders, transfers, waste events, and stock counts into a unified stock event stream. Uses `ROW_NUMBER() OVER (PARTITION BY SRC_KEY, EVENT_BEHANIOUR)` to deduplicate overlapping records across event sources, prioritising by `priority_id`. |

### Entity Mappings (22 total)

Source: `MarketMan001_Mapping.sql`, generated 2026-01-28.

**Hubs (9):**

| Entity | Source Table | Hub Key | Description |
|---|---|---|---|
| `CUSTORDER` | `MMAN_LINEITEM` | `HEADER_ID` | Sales order header (from sales summary) |
| `INVITEM` | *(from inv items staging)* | item ID | Inventory item master |
| `INVREPORT` | *(from report staging)* | report ID | Actual vs theoretical report |
| `LINEITEM` | `MMAN_LINEITEM` | `SRC_KEY` | Sales line item |
| `LOCATION` | `MMAN_LOCATION` | `storeId` | Store/location |
| `PRODUCT` | `MMAN_PRODUCT` | `PosCode` | Menu product |
| `STOCKEVENT` | `MMAN_STOCKEVENT` | `SRC_KEY` | Unified stock movement event |
| `STOCKORDER` | `MMAN_STOCKORDER` | order key | Purchase stock order |
| `SUPPLIER` | `MMAN_VENDORS` | vendor GUID | Vendor/supplier |

**Links (13):**

| Entity | Source Table | Description |
|---|---|---|
| `CUSTORDER_LINEITEM` | `MMAN_LINEITEM` | Order to line item |
| `CUSTORDER_LOCATION` | `MMAN_LINEITEM` | Order to location |
| `CUSTORDER_OCCASION` | `MMAN_LINEITEM` | Order to occasion |
| `INVITEM_INVITEM` | *(from inv items)* | Inventory item self-reference (prep components) |
| `INVITEM_INVREPORT` | *(from report)* | Inventory item to report |
| `INVITEM_LOCATION_OCCASION_PRODUCT` | `MMAN_PRODUCT` | Inventory item to LOP ternary |
| `INVITEM_STOCKEVENT` | `MMAN_STOCKEVENT` | Inventory item to stock event |
| `INVITEM_STOCKORDER` | `MMAN_STOCKORDER` | Inventory item to stock order |
| `INVREPORT_LOCATION` | *(from report)* | Report to location |
| `LINEITEM_OCCASION` | `MMAN_LINEITEM` | Line item to occasion |
| `LINEITEM_PRODUCT` | `MMAN_LINEITEM` | Line item to product |
| `LOCATION_OCCASION_PRODUCT` | `MMAN_PRODUCT` | Ternary link: product at location for occasion (Type 2 SCD; see Notable Patterns) |
| `LOCATION_STOCKEVENT` | `MMAN_STOCKEVENT` | Location to stock event |

### Notable Patterns

**Type 2 SCD on `LOCATION_OCCASION_PRODUCT`:** This is the most significant design feature of the MarketMan integration. The entity mapping for `LOCATION_OCCASION_PRODUCT` declares `type2_columns` tracking price and cost changes:

```json
// MarketMan001_Mapping.sql, line 478
"type2_columns": '["NET_PRICE", "NET_COST"]'
```

This means that whenever a menu item's `MenuItemPrice` or `RecipeIngredientsCost` changes for a given location-occasion combination, the platform inserts a new version row in the Data Vault satellite rather than overwriting the existing one. This enables historical price and margin analysis.

The entity columns mapping is:

| Source Column | Entity Column |
|---|---|
| `PosCode` | `PRODUCT_ID` |
| `storeId` (hash) | `LOCATION_HUB_ID` |
| `OCC_ID` (hash) | `OCCASION_HUB_ID` |
| `MenuItemPrice` | `NET_PRICE` *(Type 2)* |
| `RecipeIngredientsCost` | `NET_COST` *(Type 2)* |
| `PosCode` (hash) | `PRODUCT_HUB_ID` |

**Unified stock event consolidation:** The Tier 2 `Stock Event` step merges four separate event types (stock orders, transfers, waste events, inventory counts) into a single `MMAN_STOCKEVENT` staging table with a consistent schema. The `EVENT_BEHAVIOUR` column classifies each record, and `ROW_NUMBER()` deduplication ensures a single canonical record per event when the same movement appears in multiple endpoints.

**`GetDeleted: True` flag:** The `inventory_items`, `inventory_preps`, and `menu_items` endpoints pass `GetDeleted: True` in the request body. This ensures soft-deleted items are included in the extract so that the Data Vault can track when items were removed without data gaps.

---

## Growyze (Inventory Integration)

**Integration Name:** `Growyze001`
**Display Name:** Growyze Version 1
**IntegrationType:** `INVENTORY`
**Schema:** `int_growyze001`
**Source:** Growyze REST API v1 (`https://prod.growyze.com`)
**Source Folder:** `C:/threerocks_data/XMS BI/Release/Growyze/`

### Files

> **Note:** Line counts are approximate snapshots and may not reflect the current file state.

| File | Lines | Description |
|---|---|---|
| `Growyze001_INIT.sql` | ~691 | Registers integration; stores endpoint JSON for 7 API endpoints; sets `IntegrationType = 'INVENTORY'`. Contains endpoint configuration JSON only — no staging or mapping logic. |
| `Growyze001_DDL.sql` | ~2,580 | DDL definitions for 57 DL tables. |
| `Growyze001_Final.sql` | 12 | Executes `[core].[UploadEntityMappings] @intSchema = N'int_growyze001'`. |

**Growyze has no staging SQL or entity mapping SQL in the release scripts.** The `Growyze001_INIT.sql` file contains endpoint configuration JSON only. Growyze data lands in DL tables but is NOT processed into the Data Vault. There are no StagingControl records and no EntityMappings records deployed for Growyze.

### API Endpoint Configuration

All endpoints use `GET` requests and paginate through a `content` array. The `lists_dicts_obj_after_unravel` config drives multi-level JSON unnesting.

| Endpoint Key | API Path | Description | Nesting Depth |
|---|---|---|---|
| `products` | `products` | Products/inventory items with allergens, barcodes, ingredients, and organizations | 2 levels |
| `recipes` | `recipes` | Recipes/dishes with ingredients, sections, elements, and nested product references | 5+ levels |
| `orders` | `orders` | Purchase orders with items, supplier contacts, approvals, and org metadata | 3 levels |
| `delivery-notes` | `delivery-notes` | Delivery notes/GRNs with products, supplier, and org metadata | 2 levels |
| `invoices` | `invoices` | Invoices with products, delivery note links, Sage accounting integration, and Xero accounting integration | 3 levels |
| `sales` | `sales` | Sales records with items, organizations, and sub-sales | 2 levels |
| `wastes` | `wastes` | Waste records by day, broken down by dish, product, and recipe with per-day waste quantities | 3 levels |

The `recipes` endpoint has the deepest nesting: a recipe contains `sections`, each section contains `elements`, each element can be either an `ingredient` or a `recipe` (recursive), and each ingredient references a `product` that itself has `allergens`, `ingredients`, and `mayContainAllergens` arrays. This produces 9 tables from a single endpoint.

### DL Tables (57 total)

Source: `Growyze001_DDL.sql`. Tables are grouped by their source endpoint. `header_identifier` parent IDs are denoted with the suffix `_id` (e.g., `delivery_id`, `recipe_id`).

#### Delivery Notes (6 tables)

| Table | Description |
|---|---|
| `DL_DELIVERYNOTES` | Delivery note header: `id`, `deliveryDate`, `status`, `supplierId`, `totalAmount`, `delivery_id` |
| `DL_DELIVERYNOTES_ORGANIZATIONS` | Organization codes associated with the delivery note |
| `DL_DELIVERYNOTES_ORGANIZATIONSNAMES` | Organization display names |
| `DL_DELIVERYNOTES_PRODUCTS` | Products received: `code`, `name`, `quantity`, `unitPrice`, `packSize`, `delivery_id` |
| `DL_DELIVERYNOTES_SUPPLIER` | Supplier embedded in delivery note: `id`, `name`, contact fields |
| `DL_DELIVERYNOTES_SUPPLIER_EMAILS` | Supplier email addresses |

#### Invoices (9 tables)

| Table | Description |
|---|---|
| `DL_INVOICES` | Invoice header: `id`, `invoiceDate`, `status`, `supplierId`, `totalAmount`, `invoice_id` |
| `DL_INVOICES_DELIVERYNOTES` | Linked delivery note references: `deliveryNoteId` |
| `DL_INVOICES_GLOBALDISCREPANCIES` | Global discrepancy records on the invoice |
| `DL_INVOICES_ORGANIZATIONS` | Organization codes on the invoice |
| `DL_INVOICES_ORGANIZATIONSNAMES` | Organization display names |
| `DL_INVOICES_PRODUCTS` | Invoice line items: `code`, `name`, `quantity`, `unitPrice`, `invoice_id` |
| `DL_INVOICES_SAGEINVOICE` | Sage accounting integration metadata: `invoiceNumber` |
| `DL_INVOICES_SAGEINVOICE_LINEITEMS` | Sage line items within the accounting record |
| `DL_INVOICES_SUPPLIER` | Supplier embedded in invoice with `emails` sub-array |

#### Orders (5 tables)

| Table | Description |
|---|---|
| `DL_ORDERS` | Purchase order header: `id`, `orderDate`, `status`, `supplierId`, `order_id` |
| `DL_ORDERS_ITEMS` | Ordered items: `productId`, `quantity`, `unitPrice`, `packSize` |
| `DL_ORDERS_ORGANIZATIONS` | Organization codes on the order |
| `DL_ORDERS_ORGANIZATIONSNAMES` | Organization display names |
| `DL_ORDERS_SUPPLIER` | Supplier embedded in order (with contacts, approvals, reminders, organizations sub-arrays) |

#### Products (6 tables)

| Table | Description |
|---|---|
| `DL_PRODUCTS` | Product/inventory item master: `id`, `name`, `categoryId`, `uom`, `cost`, `product_id` |
| `DL_PRODUCTS_ALLERGENS` | Allergen tags on the product |
| `DL_PRODUCTS_BARCODES` | Barcode values associated with the product |
| `DL_PRODUCTS_INGREDIENTS` | Ingredient sub-components of the product |
| `DL_PRODUCTS_MAYCONTAINALLERGENS` | May-contain allergen declarations |
| `DL_PRODUCTS_ORGANIZATIONS` | Organization assignments |

#### Recipes (18 tables)

| Table | Description |
|---|---|
| `DL_RECIPES` | Recipe header: `id`, `name`, `categoryId`, `yield`, `uom`, `recipe_id` |
| `DL_RECIPES_ALLERGENS` | Allergen tags on the recipe |
| `DL_RECIPES_DISHES` | Dish associations: `id` (dish) |
| `DL_RECIPES_INGREDIENTS` | Top-level ingredients of the recipe |
| `DL_RECIPES_INGREDIENTS_PRODUCT` | Product referenced by top-level ingredient |
| `DL_RECIPES_INGREDIENTS_PRODUCT_ALLERGENS` | Allergens on the ingredient product |
| `DL_RECIPES_INGREDIENTSINPRODUCTS` | Ingredients-in-products cross-reference |
| `DL_RECIPES_MAYCONTAINALLERGENS` | May-contain allergen declarations for the recipe |
| `DL_RECIPES_ORGANIZATIONS` | Organization assignments |
| `DL_RECIPES_SECTIONS` | Recipe sections: `name` |
| `DL_RECIPES_SECTIONS_ELEMENTS` | Elements within each section: `type` (ingredient or recipe) |
| `DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT` | Ingredient-type element detail |
| `DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT_PRODUCT` | Product referenced by the section ingredient |
| `DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT_PRODUCT_ALLERGENS` | Allergens on that product |
| `DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT_PRODUCT_INGREDIENTS` | Sub-ingredients of the product |
| `DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT_PRODUCT_MAYCONTAINALLERGENS` | May-contain declarations |
| `DL_RECIPES_SECTIONS_ELEMENTS_RECIPE` | Recursive recipe-type element: embedded sub-recipe reference |

#### Sales (2 tables)

| Table | Description |
|---|---|
| `DL_SALES` | Sales record: `id`, `saleDate`, `totalAmount`, `organizationId`, `sales_id` |
| `DL_SALES_ORGANIZATIONS` | Organization codes on the sale |

#### Wastes (11 tables)

| Table | Description |
|---|---|
| `DL_WASTES` | Waste day header: `id`, `wasteDate`, `organizationId`, `waste_day_id` |
| `DL_WASTES_DISHES` | Dish waste grouping entries |
| `DL_WASTES_DISHES_DISH` | Dish reference within the waste entry: `id`, `name` |
| `DL_WASTES_DISHES_WASTESPERDAY` | Per-day waste quantity for each dish |
| `DL_WASTES_ORGANIZATIONS` | Organization codes on the waste record |
| `DL_WASTES_ORGANIZATIONSNAMES` | Organization display names |
| `DL_WASTES_PRODUCTS` | Product waste grouping entries |
| `DL_WASTES_PRODUCTS_PRODUCT` | Product reference: `id`, `name` |
| `DL_WASTES_PRODUCTS_WASTESPERDAY` | Per-day waste quantity for each product |
| `DL_WASTES_RECIPES` | Recipe waste grouping entries |
| `DL_WASTES_RECIPES_RECIPE` | Recipe reference: `id`, `name` |
| `DL_WASTES_RECIPES_WASTESPERDAY` | Per-day waste quantity for each recipe |

### Notable Patterns

**No staging or mapping in release scripts:** Unlike the other API integrations, Growyze has no `_Staging.sql` or `_Mapping.sql` files and none are embedded elsewhere. The `INIT` file contains only API endpoint configuration JSON. Growyze DL tables are populated by the extraction engine but the data is not processed further into the Data Vault via the standard StagingControl/EntityMappings pipeline. The INIT file is longer than most (~691 lines) due to the complexity of the endpoint JSON configuration for its 7 endpoints and their deep nesting specifications.

**Deep recursive nesting for recipes:** The `recipes` endpoint configuration in the INIT file describes a 5-level nesting tree. The `lists_dicts_obj_after_unravel` key (note: `lists_dicts_obj_after_unravel`, not `lists_obj_after_unravel` as in NCR/MarketMan) indicates a slightly different unravelling strategy suited to Growyze's mixed dict/list API responses.

**Accounting system integration tables:** The invoice endpoint produces dedicated tables for both Sage (`DL_INVOICES_SAGEINVOICE`, `DL_INVOICES_SAGEINVOICE_LINEITEMS`) and Xero accounting integrations (defined in the endpoint config but not materialised as separate DL tables — the Xero data lands in the main `DL_INVOICES` table via the JSON unravel).

**`NoValidID` sentinel:** Several arrays in Growyze's API (allergens, barcodes, ingredients, organizations, globalDiscrepancies) do not contain a reliable unique identifier field. The config uses `"NoValidID"` as the identifier key, instructing the extraction engine to generate a synthetic row identifier from the parent key and array position, rather than attempting to hash a natural key.

---

## SurveyHero (Survey Integration)

**Integration Name:** `SurveyHero001`
**Display Name:** Survey Hero Version 1
**IntegrationType:** `SURVEY`
**Schema:** `int_surveyhero001`
**Source:** SurveyHero REST API v1 (`https://api.surveyhero.com`)
**Source Folder:** `C:/threerocks_data/XMS BI/Release/SurveyHero/`

### Files

> **Note:** Line counts are approximate snapshots and may not reflect the current file state.

| File | Lines | Description |
|---|---|---|
| `SurveyHero001_INIT.sql` | ~161 | Registers integration; stores endpoint JSON for 7 configured endpoints; sets `IntegrationType = 'SURVEY'`. Includes pagination config (`has_more` / `page`). |
| `SurveyHero001_DDL.sql` | ~360 | DDL definitions for 8 core DL tables (the responses endpoint produces an additional 10+ tables referenced in staging). |
| `SurveyHero001_Staging.sql` | ~760 | 3 staging control steps across two tiers. |
| `SurveyHero001_Mapping.sql` | ~150 | 4 entity mapping definitions. |
| `SurveyHero001_Final.sql` | 12 | Executes `[core].[UploadEntityMappings] @intSchema = N'int_surveyhero001'`. |
| `SAT_QUESTION_MDM.sql` | 9 | Manual data correction script for `[datavault].[SAT_QUESTION]`. |

### API Endpoint Configuration

SurveyHero uses page-based pagination: `"pagination_flag_key": "has_more"`, `"pagination_value_key": "page"`. The API returns `has_more: true` when additional pages exist, and the page number increments per request.

There are 7 configured endpoint keys in the INIT JSON:

| Endpoint Key | API Path | Description |
|---|---|---|
| `surveys` | `surveys` | List of all surveys; explodes `surveys` array |
| `survey_details` | `surveys/{survey_id}` | Full survey metadata per survey ID |
| `elements` | `surveys/{survey_id}/elements` | Survey element list; explodes `elements` array |
| `elements_questions` | `surveys/{survey_id}/elements` | Question-level detail; unnests `question` sub-object |
| `elements_choice_lists` | `surveys/{survey_id}/elements` | Choice list settings; unnests `question`, `choice_list`, `settings` |
| `elements_choice_list_choices` | `surveys/{survey_id}/elements` | Individual choices within choice lists; explodes `choices` |
| `elements_choice_tables` | `surveys/{survey_id}/elements` | Table-type question settings; unnests `choice_table`, `settings` |

> **Note:** The `responses` endpoint is not configured in the INIT JSON — see the DL table DDL for how `DL_RESPONSES*` tables are structured. These tables are nonetheless referenced in the staging SQL.

The `elements` endpoint family is called repeatedly with the same URL path but different `unravel_properties` configurations, each producing a different DL table by unnesting different JSON sub-objects.

### DL Tables

Source: `SurveyHero001_DDL.sql` (8 core DL tables declared in DDL) plus additional tables referenced in the staging SQL.

#### Core DL Tables (declared in DDL file — 8 tables)

| Table | Key Columns | Description |
|---|---|---|
| `DL_ANSWERS` | `survey_id`, `response_id`, `element_id`, `question_text`, `answer_type`, `text_value`, `number_value`, `file_value` | Base answer record with union of answer type fields |
| `DL_ANSWERS_CHOICES` | `survey_id`, `response_id`, `element_id`, `choice_id`, `label`, `image_url`, `row_id` | Exploded choice selections from answers |
| `DL_ANSWERS_INPUT_TABLE` | `survey_id`, `response_id`, `element_id`, `row_id`, `column_id`, `value` | Table-type answer cell values |
| `DL_ANSWERS_RANKING` | `survey_id`, `response_id`, `element_id`, `choice_id`, `rank` | Ranking question answer positions |
| `DL_ELEMENTS` | `survey_id`, `element_id`, `type`, `question_text`, `description_text`, `question_type`, `is_required`, `settings_json` | Survey element definitions |
| `DL_ELEMENTS_CHOICES` | `survey_id`, `element_id`, `choice_id`, `label`, `image_url`, `row_id`, `column_id` | Choices available within each element |
| `DL_RESPONSES` | `survey_id`, `response_id`, `collector_id`, `started_on`, `last_updated_on`, `access_code`, `email_address`, `recipient_data`, `link_parameters`, `language`, `ip_address`, `meta_data_device`, `meta_data_user_agent`, `status` | Survey response header |
| `DL_SURVEYS` | `survey_id`, `title`, `language`, `created_on`, `modified_on`, `settings_is_anonymous`, `status` | Survey metadata |

#### Additional DL Tables (referenced in staging SQL)

These tables are populated by the responses endpoint and referenced in the `Survey Hero Main` staging step join logic:

| Table | Description |
|---|---|
| `DL_RESPONSES_ANSWERS` | Answer records per response with `answer_element_id`, `answer_question_text`, `answer_type` |
| `DL_RESPONSES_ANSWERS_CHOICES` | Choice-type answer selections: `choice_id`, `label` |
| `DL_RESPONSES_ANSWERS_CHOICETABLES` | Table-question row selections: `row_id`, `row_label` |
| `DL_RESPONSES_ANSWERS_CHOICETABLES_CHOICES` | Cell-level table answer values: `choice_id`, `label` |
| `DL_RESPONSES_ANSWERS_DATES` | Date-type answer values: `value` |
| `DL_RESPONSES_ANSWERS_INPUTS` | Free-text input answers: `input_id`, `label` |
| `DL_RESPONSES_ANSWERS_NUMBERS` | Numeric answer values: `value` |
| `DL_RESPONSES_ANSWERS_RANKINGS_NOTAPPLICABLE` | N/A selections in ranking questions: `choice_id`, `label` |
| `DL_RESPONSES_ANSWERS_RANKINGS_RANKED` | Ranked selections in ranking questions: `choice_id`, `label`, `rank` |
| `DL_RESPONSES_ANSWERS_TEXTS` | Long-text answer values: `value` |
| `DL_ELEMENTS_QUESTIONS` | Question elements with `question_text`, `description_text` |
| `DL_ELEMENTS_QUESTIONS_CHOICELISTS_CHOICES` | Choice list options per question: `choice_id`, `label` |
| `DL_ELEMENTS_QUESTIONS_RATINGSCALES` | Rating scale settings: `left_label`, `left_value`, `right_label`, `right_value` |
| `DL_ELEMENTS_TEXTS` | Text-type element content |

### Staging Steps (3 total)

Source: `SurveyHero001_Staging.sql`, generated 2026-01-22.

#### Tier 1 (1 step)

| Step Name | Staging Table | Description |
|---|---|---|
| Element Mapping Table | `SH_ELEMENT_MAPPING` | A hardcoded lookup table populated from a `VALUES` clause. Maps `survey_id` and `element_id` to `parent_element_id`. This establishes a manual parent-child hierarchy for survey `2021183` that cannot be derived from the API response alone. Contains ~100+ explicit element-to-parent mappings. |

#### Tier 2 (2 steps)

| Step Name | Staging Table | Description |
|---|---|---|
| Survey Hero Main | `SH_MAIN` | Central fact staging table. Joins `DL_RESPONSES` to all 9 answer type tables via `LEFT OUTER JOIN`. Uses `COALESCE` across all answer type columns to derive `answer_id` and `answer_label` regardless of question type. Produces: `TOUCHPOINT_ID` (survey + response), `QUESTION_ID` (element_id), `ANSWER_ID`, `ANSWER`, `TOUCHPOINT_STATUS`, `TOUCHPOINT_DATE`, `TOUCHPOINT_TYPE = 'SURVEY'`. |
| Survey Hero Questions | `SH_QUESTIONS` | Question hierarchy staging. Joins `DL_ELEMENTS_QUESTIONS` to `SH_ELEMENT_MAPPING` for parent context, `DL_ELEMENTS_QUESTIONS_CHOICELISTS_CHOICES` for choice labels, and `DL_ELEMENTS_QUESTIONS_RATINGSCALES` for scale labels. Applies `REPLACE(question_text, '&amp;', '&')` HTML entity decoding. Includes a `UNION ALL` to generate synthetic rating scale sub-questions from `left_label` values. |

### Entity Mappings (4 total)

Source: `SurveyHero001_Mapping.sql`.

| Entity | Source Table | Entity Columns | Description |
|---|---|---|---|
| `TOUCHPOINT` | `SH_MAIN` | `HUB_ID`, `TOUCHPOINT_ID`, `TOUCHPOINT_STATUS`, `TOUCHPOINT_DATE`, `TOUCHPOINT_TYPE` | Survey response hub |
| `QUESTION` | `SH_QUESTIONS` | `HUB_ID`, `QUESTION_ID`, `QUESTION_TEXT`, `PARENT_ID`, `BOTTOM_LEVEL`, `LEVEL_NAME` | Survey question hub (hierarchical) |
| `ANSWER` | `SH_MAIN` | `HUB_ID`, `ANSWER_ID`, `ANSWER`, `ANSWER_LEVEL_NAME`, `BOTTOM_LEVEL` | Answer option hub |
| `ANSWER_QUESTION_TOUCHPOINT` | `SH_MAIN` | `TOUCHPOINT_HUB_ID`, `QUESTION_HUB_ID`, `ANSWER_HUB_ID` | Ternary link: a specific answer to a specific question within a specific survey response |

### MDM Pattern — SAT_QUESTION_MDM.sql

The file `SAT_QUESTION_MDM.sql` is a post-load manual data correction script targeting the Data Vault satellite `[datavault].[SAT_QUESTION]`. It performs two operations:

```sql
-- SAT_QUESTION_MDM.sql, lines 1–8
UPDATE [datavault].[SAT_QUESTION]
SET MICROSERVICE_NAME = REPLACE(QUESTION, '&amp;', '&');

UPDATE [datavault].[SAT_QUESTION]
SET MICROSERVICE_NAME = 'Activities & provision for family groups — adults & children of all ages'
WHERE HUB_ID IN (0x422C760875C47E9F...);
```

**Operation 1** performs a bulk HTML entity decode on all question text, replacing `&amp;` with `&` in the `MICROSERVICE_NAME` column. This handles HTML-encoded characters that survive through the standard staging pipeline.

**Operation 2** applies a targeted override for a specific question (identified by its binary `HUB_ID` hash) whose text cannot be correctly decoded automatically — likely because the original contains a non-ASCII character (indicated by the `—` dash and surrounding context) that requires manual specification.

This is the MDM (Master Data Management) pattern in XMS BI: after automated loading, a separate correction script is run to standardise or override values that cannot be cleanly derived from source data alone.

### Notable Patterns

**9-way `COALESCE` answer resolution:** The `Survey Hero Main` staging step handles 9 distinct answer type tables through left joins and resolves the final `answer_id` and `answer_label` using nested `COALESCE`:

```sql
-- SurveyHero001_Staging.sql, line 310
COALESCE(AC.[choice_id], ACTC.[choice_id], AI.[input_id], AITC.[choice_id],
         ARN.[choice_id], ARR.[choice_id]) AS answer_id
,COALESCE(AC.[label], ACTC.[label], AI.[label], AITC.[label],
          ARN.[label], ARR.[label], AD.[value], AN.[value], ATe.[value]) AS answer_label
```

**Hardcoded element mapping:** The `SH_ELEMENT_MAPPING` staging step uses a `VALUES` clause with over 100 explicit `(survey_id, element_id, parent_element_id)` tuples. This is a deliberate design choice to establish the question hierarchy for a specific survey (`2021183`) that the API does not return in parent-child form. This lookup table is consumed by `SH_QUESTIONS` to build the `PARENT_ID` column used in the Data Vault hierarchy.

**`UNION ALL` for rating scale sub-questions:** The `Survey Hero Questions` step synthesises additional question rows for rating scale left-labels using `UNION ALL`, creating virtual question nodes (with composite `QUESTION_ID` of `parent_element_id-left_label`) that represent the rating scale endpoints as addressable question entities.

---

## TROAP (POS Integration)

**Integration Name:** `TROaP001`
**Display Name:** Three Rocks OaP Version 1
**IntegrationType:** `POS`
**Schema:** `int_troap001`
**Source:** Internal Three Rocks OaP application database (direct SQL read)
**Source Folder:** `C:/threerocks_data/XMS BI/Release/TROAP/`

### Files

> **Note:** Line counts are approximate snapshots and may not reflect the current file state.

| File | Lines | Description |
|---|---|---|
| `TROAP001_INIT.sql` | ~167 | Registers integration; stores table configuration JSON listing 41 source tables with optional `delta_columns` and `parent_table` definitions; sets `IntegrationType = 'POS'`. |
| `TROAP001_DDL.sql` | ~2,260 | DDL definitions for 41 DL tables mirroring the source application database schema. |
| `TROAP001_Final.sql` | 12 | Executes `[core].[UploadEntityMappings] @intSchema = N'int_troap001'`. |

**Key difference from other integrations:** TROAP has no `_Staging.sql` or `_Mapping.sql` files. Unlike the API integrations, TROAP reads directly from an internal SQL Server database using a table-copy approach. The staging and mapping steps are not required because the extraction is a full or delta table copy rather than an API endpoint unravel.

### Source Configuration

TROAP's INIT file stores a `"tables"` JSON object (not an `"endpoints"` object) listing each source table as `"[dbo].[TableName]"`. Tables have three possible configurations:

1. **No delta config** — Full extract on each run (static/reference tables)
2. **`delta_columns`** — Delta extract using one or two timestamp columns (`DateUpdated`, `DateCreated`, `DateProcessed`)
3. **`parent_table` + `fk_column`** — Child-table delta extraction driven by the parent table's delta

### Delta Extraction Pattern

The parent-child pattern is the key engineering feature of TROAP. Child tables that lack their own `DateUpdated` column instead inherit the parent's delta window:

```json
// TROAP001_INIT.sql, lines 68–84 (example: CustomerOpenCheckCharge)
"[dbo].[CustomerOpenCheckCharge]": {
  "parent_table": "[dbo].[CustomerOpenCheck]",
  "parent_table_key_column": "Id",
  "parent_table_delta_columns": ["DateUpdated", "DateCreated"],
  "fk_column": "CustomerOpenCheckId"
}
```

In this pattern, the extraction engine queries `CustomerOpenCheck` for records modified in the delta window, collects their `Id` values, and uses them to filter `CustomerOpenCheckCharge` via `CustomerOpenCheckId IN (...)`. This ensures child records are always refreshed when their parent is modified, even if the child table has no timestamp of its own.

### DL Tables (41 total)

Source: `TROAP001_DDL.sql`, lines 6–2260. Tables mirror the source `[dbo].*` schema. Column naming preserves PascalCase from the source application.

#### Reference / Static Tables (no delta config)

| Table | Source Table | Description |
|---|---|---|
| `DL_Address` | `[dbo].[Address]` | Address records |
| `DL_Allergen` | `[dbo].[Allergen]` | Allergen definitions |
| `DL_AllowedStores` | `[dbo].[AllowedStores]` | Store permission assignments |
| `DL_AvailabilityRule` | `[dbo].[AvailabilityRule]` | Product availability rules |
| `DL_AvailabilityRuleValidDays` | `[dbo].[AvailabilityRuleValidDays]` | Valid days per availability rule |
| `DL_CouponDiscount` | `[dbo].[CouponDiscount]` | Coupon and discount definitions |
| `DL_Device` | `[dbo].[Device]` | Registered ordering devices |
| `DL_Menu` | `[dbo].[Menu]` | Menu definitions |
| `DL_MenuCategory` | `[dbo].[MenuCategory]` | Menu category structure |
| `DL_MenuCategoryGroup` | `[dbo].[MenuCategoryGroup]` | Menu category groupings |
| `DL_MenuPriceBand` | `[dbo].[MenuPriceBand]` | Price band definitions |
| `DL_MenuProduct` | `[dbo].[MenuProduct]` | Menu-to-product associations |
| `DL_Price` | `[dbo].[Price]` | Product price records |
| `DL_Product` | `[dbo].[Product]` | Product master with full attribute set |
| `DL_ProductBase` | `[dbo].[ProductBase]` | Base product template |
| `DL_ProductCategory` | `[dbo].[ProductCategory]` | Product category assignments |
| `DL_Store` | `[dbo].[Store]` | Store/location master |
| `DL_StoreOpeningHours` | `[dbo].[StoreOpeningHours]` | Store opening time schedules |
| `DL_StoreOpeningHoursGroup` | `[dbo].[StoreOpeningHoursGroup]` | Opening hours groupings |
| `DL_StoreOrderType` | `[dbo].[StoreOrderType]` | Order type configuration per store |
| `DL_StoreProductOutOfStock` | `[dbo].[StoreProductOutOfStock]` | Out-of-stock flags |
| `DL_ZonalMenu` | `[dbo].[ZonalMenu]` | Zonal menu assignments |
| `DL_ZonalProduct` | `[dbo].[ZonalProduct]` | Zonal product assignments |

#### Delta Tables — Own Timestamp

| Table | Source Table | Delta Columns |
|---|---|---|
| `DL_Basket` | `[dbo].[Basket]` | `DateUpdated`, `DateCreated` |
| `DL_BasketItem` | `[dbo].[BasketItem]` | `DateUpdated`, `DateCreated` |
| `DL_BrainTreePaymentIntent` | `[dbo].[BrainTreePaymentIntent]` | `DateUpdated`, `DateCreated` |
| `DL_BrainTreePaymentLog` | `[dbo].[BrainTreePaymentLog]` | `DateCreated` |
| `DL_Customer` | `[dbo].[Customer]` | `DateUpdated`, `DateCreated` |
| `DL_CustomerOpenCheck` | `[dbo].[CustomerOpenCheck]` | `DateUpdated`, `DateCreated` |
| `DL_CustomerOpenCheckBasket` | `[dbo].[CustomerOpenCheckBasket]` | `DateCreated` |
| `DL_Order` | `[dbo].[Order]` | `DateUpdated`, `DateCreated` |
| `DL_OrderItem` | `[dbo].[OrderItem]` | `DateUpdated`, `DateCreated` |
| `DL_OrderPayment` | `[dbo].[OrderPayment]` | `DateUpdated`, `DateCreated` |
| `DL_OrderRefundQueue` | `[dbo].[OrderRefundQueue]` | `DateCreated`, `DateProcessed` |
| `DL_OrderSplitBill` | `[dbo].[OrderSplitBill]` | `DateCreated` |
| `DL_OrderSplitBillItem` | `[dbo].[OrderSplitBillItem]` | `DateUpdated` |

#### Delta Tables — Parent-Driven

| Table | Source Table | Parent Table | FK Column |
|---|---|---|---|
| `DL_CustomerOpenCheckCharge` | `[dbo].[CustomerOpenCheckCharge]` | `CustomerOpenCheck` | `CustomerOpenCheckId` |
| `DL_CustomerOpenCheckCouponDiscount` | `[dbo].[CustomerOpenCheckCouponDiscount]` | `CustomerOpenCheck` | `CustomerOpenCheckId` |
| `DL_CustomerOpenCheckDiscount` | `[dbo].[CustomerOpenCheckDiscount]` | `CustomerOpenCheck` | `CustomerOpenCheckId` |
| `DL_CustomerOpenCheckPromotion` | `[dbo].[CustomerOpenCheckPromotion]` | `CustomerOpenCheck` | `CustomerOpenCheckId` |
| `DL_OrderSplitBillPayment` | `[dbo].[OrderSplitBillPayment]` | `OrderSplitBill` | `OrderSplitBillId` |

### Notable Patterns

**Direct database integration (no API):** TROAP is the only integration that reads from an internal SQL Server application database rather than an external REST API. The INIT file's `"integration_info": {"source": "troap"}` (with no `"base_url"`) signals the extraction engine to use a database connection rather than HTTP. The `"tables"` config object replaces the `"endpoints"` config used in all other integrations.

**PascalCase column naming:** All DL table columns in TROAP preserve the source application's PascalCase naming convention (e.g., `DateUpdated`, `CustomerOpenCheckId`, `TotalAmount`), as opposed to the camelCase or snake_case used by the API integrations. This means no column renaming is needed in the DDL, reducing transformation complexity.

**OrderSplitBill hierarchy:** The `OrderSplitBill` → `OrderSplitBillPayment` parent-child pair demonstrates the pattern for tables that record payment splits: the payment table lacks its own modification timestamp and relies entirely on the parent split-bill record's `DateCreated` for delta detection.

**`DL_Order` as the central fact table:** The `DL_Order` table is the primary transaction record, equivalent to `DL_SALES_STREAM` in NCR Aloha. It tracks `DateUpdated` and `DateCreated`, ensuring all order modifications are captured incrementally. `DL_OrderItem`, `DL_OrderPayment`, and `DL_OrderSplitBill` are direct children.

---

## Cross-Integration Patterns

This section summarises architectural patterns that appear across multiple integrations.

### DL Table Naming Convention

All raw landing tables follow the prefix convention `DL_` (Data Landing). The full table name reflects the API source and, where applicable, the nested array path:

- **Flat endpoint:** `DL_SALES`, `DL_STORE`
- **One level of nesting:** `DL_ORDERS_BY_SENTDATE_ITEMS` (endpoint `orders_by_sentDate` → child array `Items`)
- **Two levels of nesting:** `DL_SALES_STREAM_CLEARS_LINKEDITEMS` (endpoint `sales_stream` → `clears` → `linkedItems`)
- **Deep nesting:** `DL_RECIPES_SECTIONS_ELEMENTS_INGREDIENT_PRODUCT_ALLERGENS` (6 levels)

### Staging Table Patterns

All staging steps follow the drop-and-recreate pattern:

```sql
IF OBJECT_ID('stage.TABLE_NAME', 'U') IS NOT NULL
    DROP TABLE [stage].[TABLE_NAME];

SELECT * INTO [stage].[TABLE_NAME]
FROM ( ... ) AS source_query;
```

This makes all staging steps fully idempotent and re-runnable without side effects.

### Entity Mapping Hash Keys

Data Vault hub identifiers are computed as binary hashes of the natural business key. In the entity mapping JSON, `"hash": 1` marks the column(s) contributing to the hub hash. Multiple columns with `"hash": 1` produce a composite hash key. Columns with `"hash": 0` become satellite attributes.

### IntegrationType Classification

| Integration | IntegrationType |
|---|---|
| NCRAloha001 | `POS` |
| Marketman001 | `INVENTORY` |
| Growyze001 | `INVENTORY` |
| SurveyHero001 | `SURVEY` |
| TROaP001 | `POS` |

The `IntegrationType` field stored in `[core].[Integrations]` determines downstream routing in the Data Vault load framework, controlling which hub/link/satellite templates are applied.

### Staging Tier Execution Order

| Tier | Purpose | Integrations Using |
|---|---|---|
| 1 | Direct DL table reads; produces normalised staging tables | All API integrations |
| 2 | Joins and aggregates Tier 1 outputs; produces link/derived tables | NCRAloha (14 steps), MarketMan (1 step), SurveyHero (2 steps) |
| 3 | Self-referencing or final resolution steps | NCRAloha only (1 step) |

### File Line Counts Summary

| Integration | Folder | INIT | DDL | Staging | Mapping | Final | Total |
|---|---|---|---|---|---|---|---|
| NCRAloha | `NCRAloha/` | ~245 | ~1,021 | ~2,680 | ~990 | 12 | ~4,948 |
| MarketMan | `MarketMan/` | ~494 | ~1,960 | ~2,280 | ~640 | 12 | ~5,386 |
| Growyze | `Growyze/` | ~691 | ~2,580 | *(none)* | *(none)* | 12 | ~3,283 |
| SurveyHero | `SurveyHero/` | ~161 | ~360 | ~760 | ~150 | 12 + 9 | ~1,452 |
| TROAP | `TROAP/` | ~167 | ~2,260 | *(n/a)* | *(n/a)* | 12 | ~2,439 |

---

*End of XMS BI Integrations Reference*
