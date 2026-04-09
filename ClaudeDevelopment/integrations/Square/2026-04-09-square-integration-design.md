# Square POS Integration Design — `Square001`

**Date:** 2026-04-09
**Status:** APPROVED
**Integration:** `Square001` / `int_square001` / IntegrationType `POS`

## 1. Overview

Square is a POS platform that also provides inventory tracking, CRM, and workforce management. This design adds Square as a new integration option in XMS BI alongside NCRAloha and TROAP, allowing organisations on Square to get full sales, inventory, CRM, and workforce analytics.

### Key Design Decisions

1. **Single integration** — all Square modules (POS, inventory, CRM, workforce) live in one `int_square001` schema. No module split. Empty DL tables for unused modules produce zero rows through the pipeline harmlessly.
2. **Separate Tier 1 staging per DL table** — unlike NCRAloha's single UNION ALL into `NCR_LINE_ITEM_DETAIL`, Square staging keeps each DL child table as its own Tier 1 step. This fits Square's nested API structure naturally and avoids a flatten → union → re-split round trip.
3. **DL tables onward only** — this design defines the DL table schemas as the contract with the API fetcher team. Fetcher/endpoint configuration (`APIEndpointDetail` JSON) is out of scope.
4. **No new DV entities** — all Square concepts map to existing entities.
5. **No presentation layer changes** — existing tables and vis queries work automatically.

### Scope

| Aspect | Detail |
|---|---|
| DL tables | 22 |
| Staging steps | 39 (22 Tier 1 + 16 Tier 2 + 1 Tier 3) |
| Entity mappings | 44 (25 hub + 19 link) |
| New DV entities | None |
| First-time entity population | TENDER hub (H5 fix), REFUND + CUSTORDER_REFUND, CRM cluster (INDIVIDUAL, ADDRESS, CONTACT + links) |
| Presentation changes | None |
| Known gaps | F_PRODUCT_MARGIN_DAY cost data, DimCustomer pipeline, DEAL mapping |
| Estimated script volume | ~5,000 lines across 5 files |

### Data Flow

```
Square API → fetcher → int_square001.DL_* tables
  → stage.SQR_* tables (Tier 1: dimensions + base facts)
  → stage.SQR_* tables (Tier 2: link staging)
  → stage.SQR_* tables (Tier 3: self-referencing links)
  → load.{ENTITY} → datavault.HUB/SAT/LNK/SAT_LNK.*
  → presentation.F_*/D_* (existing tables, no changes)
  → VisualisationQueries (existing queries, no changes)
```

---

## 2. DL Table Inventory

All columns `NVARCHAR(MAX) NULL` plus the two mandatory system columns (`LOADTS_UTC`, `INT_FETCH_DATE`). Column names match Square's API response fields.

### 2.1 Orders Endpoint (SearchOrders) — 8 Tables

**`DL_ORDERS`** — Order headers

| Column | Square Source |
|---|---|
| `id` | Order.id |
| `location_id` | Order.location_id |
| `state` | Order.state (OPEN/COMPLETED/CANCELED) |
| `source_name` | Order.source.name |
| `created_at` | Order.created_at |
| `updated_at` | Order.updated_at |
| `closed_at` | Order.closed_at |
| `total_money_amount` | Order.total_money.amount (integer, lowest denomination) |
| `total_money_currency` | Order.total_money.currency |
| `total_tax_money_amount` | Order.total_tax_money.amount |
| `total_discount_money_amount` | Order.total_discount_money.amount |
| `total_tip_money_amount` | Order.total_tip_money.amount |
| `total_service_charge_money_amount` | Order.total_service_charge_money.amount |
| `net_amount_due_money_amount` | Order.net_amount_due_money.amount |
| `ticket_name` | Order.ticket_name |
| `customer_id` | Order.customer_id |
| `reference_id` | Order.reference_id |

**`DL_ORDERS_LINEITEMS`** — Order line items

| Column | Square Source |
|---|---|
| `order_id` | Parent Order.id |
| `location_id` | Parent Order.location_id |
| `uid` | OrderLineItem.uid |
| `name` | OrderLineItem.name |
| `quantity` | OrderLineItem.quantity (string) |
| `catalog_object_id` | OrderLineItem.catalog_object_id |
| `catalog_version` | OrderLineItem.catalog_version |
| `variation_name` | OrderLineItem.variation_name |
| `item_type` | OrderLineItem.item_type (ITEM/CUSTOM_AMOUNT/GIFT_CARD) |
| `base_price_money_amount` | OrderLineItem.base_price_money.amount |
| `base_price_money_currency` | OrderLineItem.base_price_money.currency |
| `gross_sales_money_amount` | OrderLineItem.gross_sales_money.amount |
| `total_tax_money_amount` | OrderLineItem.total_tax_money.amount |
| `total_discount_money_amount` | OrderLineItem.total_discount_money.amount |
| `total_money_amount` | OrderLineItem.total_money.amount |
| `note` | OrderLineItem.note |

**`DL_ORDERS_LINEITEMS_MODIFIERS`** — Modifiers applied to line items

| Column | Square Source |
|---|---|
| `order_id` | Parent Order.id |
| `location_id` | Parent Order.location_id |
| `lineitem_uid` | Parent OrderLineItem.uid |
| `uid` | OrderLineItemModifier.uid |
| `catalog_object_id` | OrderLineItemModifier.catalog_object_id |
| `name` | OrderLineItemModifier.name |
| `quantity` | OrderLineItemModifier.quantity |
| `base_price_money_amount` | OrderLineItemModifier.base_price_money.amount |
| `total_price_money_amount` | OrderLineItemModifier.total_price_money.amount |

**`DL_ORDERS_LINEITEMS_TAXES`** — Taxes applied to line items

| Column | Square Source |
|---|---|
| `order_id` | Parent Order.id |
| `location_id` | Parent Order.location_id |
| `lineitem_uid` | Parent OrderLineItem.uid |
| `tax_uid` | OrderLineItemAppliedTax.tax_uid |
| `catalog_object_id` | Referenced CatalogTax.id |
| `name` | Tax name |
| `type` | ADDITIVE/INCLUSIVE |
| `percentage` | Tax percentage |
| `applied_money_amount` | OrderLineItemAppliedTax.applied_money.amount |

**`DL_ORDERS_LINEITEMS_DISCOUNTS`** — Discounts applied to line items

| Column | Square Source |
|---|---|
| `order_id` | Parent Order.id |
| `location_id` | Parent Order.location_id |
| `lineitem_uid` | Parent OrderLineItem.uid |
| `discount_uid` | OrderLineItemAppliedDiscount.discount_uid |
| `catalog_object_id` | Referenced CatalogDiscount.id |
| `name` | Discount name |
| `type` | FIXED_PERCENTAGE/FIXED_AMOUNT/VARIABLE_PERCENTAGE/VARIABLE_AMOUNT |
| `percentage` | Discount percentage (if percentage-based) |
| `amount_money_amount` | Fixed discount amount |
| `applied_money_amount` | Actual amount applied |
| `scope` | ORDER/LINE_ITEM |

**`DL_ORDERS_SERVICECHARGES`** — Service charges on orders

| Column | Square Source |
|---|---|
| `order_id` | Parent Order.id |
| `location_id` | Parent Order.location_id |
| `uid` | OrderServiceCharge.uid |
| `name` | OrderServiceCharge.name |
| `catalog_object_id` | OrderServiceCharge.catalog_object_id |
| `percentage` | Percentage if percentage-based |
| `amount_money_amount` | OrderServiceCharge.amount_money.amount |
| `total_money_amount` | OrderServiceCharge.total_money.amount |
| `type` | AUTO_GRATUITY/CUSTOM |
| `taxable` | Boolean string |
| `calculation_phase` | SUBTOTAL_PHASE/TOTAL_PHASE |

**`DL_ORDERS_TENDERS`** — Payment tenders on orders

| Column | Square Source |
|---|---|
| `order_id` | Parent Order.id |
| `location_id` | Parent Order.location_id |
| `id` | Tender.id |
| `type` | CARD/CASH/THIRD_PARTY_CARD/SQUARE_GIFT_CARD/NO_SALE/BANK_ACCOUNT/SQUARE_ACCOUNT/OTHER |
| `amount_money_amount` | Tender.amount_money.amount (includes tip) |
| `tip_money_amount` | Tender.tip_money.amount |
| `processing_fee_money_amount` | Tender.processing_fee_money.amount |
| `customer_id` | Tender.customer_id |
| `payment_id` | Tender.payment_id |
| `created_at` | Tender.created_at |
| `note` | Tender.note |

**`DL_ORDERS_FULFILLMENTS`** — Order fulfillment records

| Column | Square Source |
|---|---|
| `order_id` | Parent Order.id |
| `location_id` | Parent Order.location_id |
| `uid` | OrderFulfillment.uid |
| `type` | PICKUP/SHIPMENT/DELIVERY/DIGITAL |
| `state` | PROPOSED/RESERVED/PREPARED/COMPLETED/CANCELED/FAILED |
| `pickup_at` | PickupDetails.pickup_at |
| `deliver_at` | DeliveryDetails.deliver_at |
| `schedule_type` | SCHEDULED/ASAP |

### 2.2 Catalog Endpoint (SearchCatalogObjects) — 7 Tables

**`DL_CATALOG_ITEMS`** — Product items

| Column | Square Source |
|---|---|
| `id` | CatalogObject.id |
| `updated_at` | CatalogObject.updated_at |
| `version` | CatalogObject.version |
| `is_deleted` | CatalogObject.is_deleted |
| `item_data_name` | CatalogItem.name |
| `item_data_description` | CatalogItem.description |
| `item_data_category_id` | CatalogItem.category_id |
| `item_data_product_type` | CatalogItem.product_type |

**`DL_CATALOG_ITEMVARIATIONS`** — Item variations (sellable units)

| Column | Square Source |
|---|---|
| `id` | CatalogObject.id |
| `updated_at` | CatalogObject.updated_at |
| `version` | CatalogObject.version |
| `is_deleted` | CatalogObject.is_deleted |
| `item_variation_data_item_id` | CatalogItemVariation.item_id |
| `item_variation_data_name` | CatalogItemVariation.name |
| `item_variation_data_sku` | CatalogItemVariation.sku |
| `item_variation_data_upc` | CatalogItemVariation.upc |
| `item_variation_data_pricing_type` | FIXED_PRICING/VARIABLE_PRICING |
| `item_variation_data_price_money_amount` | CatalogItemVariation.price_money.amount |
| `item_variation_data_price_money_currency` | CatalogItemVariation.price_money.currency |
| `item_variation_data_track_inventory` | Boolean string |
| `item_variation_data_measurement_unit_id` | CatalogItemVariation.measurement_unit_id |

**`DL_CATALOG_CATEGORIES`** — Product categories

| Column | Square Source |
|---|---|
| `id` | CatalogObject.id |
| `updated_at` | CatalogObject.updated_at |
| `is_deleted` | CatalogObject.is_deleted |
| `category_data_name` | CatalogCategory.name |
| `category_data_parent_category_id` | CatalogCategory.parent_category.id |
| `category_data_is_top_level` | CatalogCategory.is_top_level |

**`DL_CATALOG_TAXES`** — Tax definitions

| Column | Square Source |
|---|---|
| `id` | CatalogObject.id |
| `updated_at` | CatalogObject.updated_at |
| `is_deleted` | CatalogObject.is_deleted |
| `tax_data_name` | CatalogTax.name |
| `tax_data_percentage` | CatalogTax.percentage |
| `tax_data_inclusion_type` | ADDITIVE/INCLUSIVE |
| `tax_data_applies_to_custom_amounts` | Boolean string |

**`DL_CATALOG_DISCOUNTS`** — Discount definitions

| Column | Square Source |
|---|---|
| `id` | CatalogObject.id |
| `updated_at` | CatalogObject.updated_at |
| `is_deleted` | CatalogObject.is_deleted |
| `discount_data_name` | CatalogDiscount.name |
| `discount_data_discount_type` | FIXED_PERCENTAGE/FIXED_AMOUNT/VARIABLE_PERCENTAGE/VARIABLE_AMOUNT |
| `discount_data_percentage` | CatalogDiscount.percentage |
| `discount_data_amount_money_amount` | CatalogDiscount.amount_money.amount |

**`DL_CATALOG_MODIFIERLISTS`** — Modifier list containers

| Column | Square Source |
|---|---|
| `id` | CatalogObject.id |
| `updated_at` | CatalogObject.updated_at |
| `is_deleted` | CatalogObject.is_deleted |
| `modifier_list_data_name` | CatalogModifierList.name |
| `modifier_list_data_selection_type` | SINGLE/MULTIPLE |

**`DL_CATALOG_MODIFIERS`** — Individual modifiers

| Column | Square Source |
|---|---|
| `id` | CatalogObject.id |
| `updated_at` | CatalogObject.updated_at |
| `is_deleted` | CatalogObject.is_deleted |
| `modifier_data_name` | CatalogModifier.name |
| `modifier_data_modifier_list_id` | CatalogModifier.modifier_list_id |
| `modifier_data_price_money_amount` | CatalogModifier.price_money.amount |

### 2.3 Locations Endpoint (ListLocations) — 1 Table

**`DL_LOCATIONS`** — Store/site master

| Column | Square Source |
|---|---|
| `id` | Location.id |
| `name` | Location.name |
| `business_name` | Location.business_name |
| `type` | PHYSICAL/MOBILE |
| `status` | ACTIVE/INACTIVE |
| `currency` | ISO 4217 (e.g. GBP) |
| `country` | ISO 3166 |
| `timezone` | IANA timezone (e.g. Europe/London) |
| `address_line_1` | Location.address.address_line_1 |
| `address_line_2` | Location.address.address_line_2 |
| `locality` | Location.address.locality |
| `administrative_district_level_1` | Location.address.administrative_district_level_1 |
| `postal_code` | Location.address.postal_code |
| `phone_number` | Location.phone_number |
| `business_email` | Location.business_email |
| `merchant_id` | Location.merchant_id |
| `created_at` | Location.created_at |

### 2.4 Inventory Endpoints — 2 Tables

**`DL_INVENTORY_COUNTS`** — Current stock levels (BatchRetrieveInventoryCounts)

| Column | Square Source |
|---|---|
| `catalog_object_id` | InventoryCount.catalog_object_id |
| `catalog_object_type` | InventoryCount.catalog_object_type |
| `state` | InventoryCount.state (IN_STOCK, SOLD, WASTE, etc.) |
| `location_id` | InventoryCount.location_id |
| `quantity` | InventoryCount.quantity (string decimal) |
| `calculated_at` | InventoryCount.calculated_at |

**`DL_INVENTORY_CHANGES`** — Stock adjustments, physical counts, transfers (BatchRetrieveInventoryChanges)

| Column | Square Source |
|---|---|
| `type` | InventoryChange.type (PHYSICAL_COUNT/ADJUSTMENT/TRANSFER) |
| `id` | Adjustment.id or PhysicalCount.id |
| `catalog_object_id` | *.catalog_object_id |
| `location_id` | *.location_id |
| `from_state` | InventoryAdjustment.from_state |
| `to_state` | InventoryAdjustment.to_state |
| `quantity` | *.quantity (string decimal) |
| `occurred_at` | *.occurred_at |
| `created_at` | *.created_at |
| `reference_id` | *.reference_id |
| `source_application_name` | *.source.name |
| `employee_id` | *.employee_id |
| `team_member_id` | *.team_member_id |
| `transaction_id` | InventoryAdjustment.transaction_id |

### 2.5 Refunds Endpoint — 1 Table

**`DL_REFUNDS`** — Payment refunds (ListPaymentRefunds)

| Column | Square Source |
|---|---|
| `id` | PaymentRefund.id |
| `payment_id` | PaymentRefund.payment_id |
| `order_id` | PaymentRefund.order_id |
| `location_id` | PaymentRefund.location_id |
| `status` | PENDING/COMPLETED/REJECTED/FAILED |
| `amount_money_amount` | PaymentRefund.amount_money.amount |
| `amount_money_currency` | PaymentRefund.amount_money.currency |
| `reason` | PaymentRefund.reason |
| `created_at` | PaymentRefund.created_at |
| `updated_at` | PaymentRefund.updated_at |

### 2.6 Customers Endpoint (SearchCustomers) — 1 Table

**`DL_CUSTOMERS`** — Customer profiles

| Column | Square Source |
|---|---|
| `id` | Customer.id |
| `created_at` | Customer.created_at |
| `updated_at` | Customer.updated_at |
| `given_name` | Customer.given_name |
| `family_name` | Customer.family_name |
| `email_address` | Customer.email_address |
| `phone_number` | Customer.phone_number |
| `company_name` | Customer.company_name |
| `address_line_1` | Customer.address.address_line_1 |
| `address_line_2` | Customer.address.address_line_2 |
| `locality` | Customer.address.locality |
| `postal_code` | Customer.address.postal_code |
| `country` | Customer.address.country |
| `reference_id` | Customer.reference_id |
| `note` | Customer.note |
| `birthday` | Customer.birthday |

### 2.7 Workforce Endpoints — 2 Tables

**`DL_TEAM_MEMBERS`** — Employee records (Team API)

| Column | Square Source |
|---|---|
| `id` | TeamMember.id |
| `status` | ACTIVE/INACTIVE |
| `given_name` | TeamMember.given_name |
| `family_name` | TeamMember.family_name |
| `email_address` | TeamMember.email_address |
| `phone_number` | TeamMember.phone_number |
| `created_at` | TeamMember.created_at |
| `updated_at` | TeamMember.updated_at |
| `is_owner` | TeamMember.is_owner |

**`DL_SHIFTS`** — Clock-in/out shift records (Labor API)

| Column | Square Source |
|---|---|
| `id` | Shift.id |
| `team_member_id` | Shift.team_member_id |
| `location_id` | Shift.location_id |
| `start_at` | Shift.start_at |
| `end_at` | Shift.end_at |
| `status` | OPEN/CLOSED |
| `wage_title` | Shift.wage.title (job title) |
| `wage_hourly_rate_amount` | Shift.wage.hourly_rate.amount |
| `wage_hourly_rate_currency` | Shift.wage.hourly_rate.currency |
| `wage_tip_eligible` | Shift.wage.tip_eligible |
| `created_at` | Shift.created_at |
| `updated_at` | Shift.updated_at |

---

## 3. Staging Steps

All steps use the standard idempotent DROP IF EXISTS + SELECT INTO pattern. Output tables in `stage.*` schema with `SQR_` prefix.

### 3.1 Tier 1 — Base Staging from DL Tables (22 Steps)

#### POS Dimensions (8 steps)

**Location** → `SQR_LOCATION` from `DL_LOCATIONS`
- `ITEM_SRC_KEY = id`
- `LOCATION_NAME = name`, `LOCATION_ID = id`
- `LEVEL_NAME = 'BOTTOM'`, `BOTTOM_LEVEL = 1`, `PARENT_ID = NULL`
- `MICROSERVICE_NAME = NULL`, `MICROSERVICE_ID = NULL`
- Dedup: `ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) = 1`

**Product** → `SQR_PRODUCT` from `DL_CATALOG_ITEMVARIATIONS` + `DL_CATALOG_ITEMS` + `DL_CATALOG_CATEGORIES`
- Three-level hierarchy via UNION ALL:
  - Variations (BOTTOM): `ITEM_SRC_KEY = variation.id`, `PRODUCT_NAME = variation.name`, `PARENT_ID = variation.item_id`, `LEVEL_NAME = 'BOTTOM'`, `BOTTOM_LEVEL = 1`
  - Items (MIDDLE_1): `ITEM_SRC_KEY = item.id`, `PRODUCT_NAME = item.name`, `PARENT_ID = item.category_id`, `LEVEL_NAME = 'MIDDLE_1'`, `BOTTOM_LEVEL = 0`
  - Categories (TOP): `ITEM_SRC_KEY = category.id`, `PRODUCT_NAME = category.name`, `PARENT_ID = category.parent_category_id`, `LEVEL_NAME = 'TOP'`, `BOTTOM_LEVEL = 0`
- Filter: `WHERE is_deleted = 'false' OR is_deleted IS NULL`
- Dedup per level: `ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) = 1`
- `MICROSERVICE_NAME = NULL`, `MICROSERVICE_ID = NULL`

**Tax** → `SQR_TAX` from `DL_CATALOG_TAXES`
- `ITEM_SRC_KEY = id`
- `TAX_NAME = tax_data_name`, `TAX_ID = id`
- `TAX_MULTIPLIER = CAST(tax_data_percentage AS DECIMAL(18,6)) / 100.0`
- `LEVEL_NAME = 'BOTTOM'`, `PARENT_ID = NULL`
- Filter: `WHERE is_deleted = 'false' OR is_deleted IS NULL`

**Discount** → `SQR_DISCOUNT` from `DL_CATALOG_DISCOUNTS`
- `ITEM_SRC_KEY = id`
- `DISCOUNT_NAME = discount_data_name`, `DISCOUNT_ID = id`
- `VALUE_TYPE = discount_data_discount_type`, `VALUE = COALESCE(discount_data_percentage, CAST(discount_data_amount_money_amount AS BIGINT) / 100.0)`
- `IS_WASTE = 0`
- `LEVEL_NAME = 'BOTTOM'`, `PARENT_ID = NULL`
- Filter: `WHERE is_deleted = 'false' OR is_deleted IS NULL`

**Modifier** → `SQR_MODIFIER` from `DL_CATALOG_MODIFIERS` + `DL_CATALOG_MODIFIERLISTS`
- Two-level hierarchy via UNION ALL:
  - Modifiers (BOTTOM): `ITEM_SRC_KEY = modifier.id`, `MOD_NAME = modifier_data_name`, `PARENT_ID = modifier_data_modifier_list_id`, `LEVEL_NAME = 'BOTTOM'`, `BOTTOM_LEVEL = 1`
  - Modifier Lists (TOP): `ITEM_SRC_KEY = list.id`, `MOD_NAME = modifier_list_data_name`, `PARENT_ID = NULL`, `LEVEL_NAME = 'TOP'`, `BOTTOM_LEVEL = 0`
- `MICROSERVICE_NAME = NULL`, `MICROSERVICE_ID = NULL`
- Filter: `WHERE is_deleted = 'false' OR is_deleted IS NULL`

**Channel** → `SQR_CHANNEL` from `DL_ORDERS`
- `SELECT DISTINCT source_name`
- `ITEM_SRC_KEY = source_name`, `CHANNEL_NAME = source_name`, `CHANNEL_ID = source_name`
- `LEVEL_NAME = 'BOTTOM'`, `BOTTOM_LEVEL = 1`

**Service Charge** → `SQR_SERVICECHARGE` from `DL_ORDERS_SERVICECHARGES`
- `SELECT DISTINCT name`
- `ITEM_SRC_KEY = name`, `SVCCHARGE_NAME = name`, `SVC_ID = name`
- `LEVEL_NAME = 'BOTTOM'`, `PARENT_ID = NULL`

**Occasion** → `SQR_OCCASION` from `DL_ORDERS_FULFILLMENTS`
- `SELECT DISTINCT COALESCE(type, 'DINE_IN')`
- `ITEM_SRC_KEY = occasion_name`, `OCCASION_NAME = occasion_name`, `OCCASSION_ID = occasion_name`
- `LEVEL_NAME = 'BOTTOM'`, `BOTTOM_LEVEL = 1`, `PARENT_ID = NULL`
- Includes synthetic 'DINE_IN' row for orders without fulfillment

#### POS Transactional (7 steps)

**Customer Order** → `SQR_CUSTORDER` from `DL_ORDERS`
- `HEADER_ID = CONCAT_WS('-', location_id, id)`
- Money fields divided by 100: `GRAND_TOTAL = CAST(total_money_amount AS BIGINT) / 100.0`
- `ORDER_DATE = created_at`, `OPEN_TIME = created_at`, `CLOSE_TIME = closed_at`
- `ORDER_STATUS = state`, `PAYMENT_STATUS = CASE WHEN net_amount_due_money_amount = '0' THEN 'PAID' ELSE 'UNPAID' END`
- `TRADING_DATE = CAST(COALESCE(closed_at, created_at) AS DATE)`
- `GUEST_COUNT = CASE WHEN customer_id IS NOT NULL THEN 1 ELSE NULL END`
- `EXTERNAL_REFERENCE = reference_id`
- Filter: `WHERE state IN ('COMPLETED', 'CANCELED')` — exclude OPEN orders

**Line Item** → `SQR_LINEITEM` from `DL_ORDERS_LINEITEMS`
- `SRC_KEY = CONCAT_WS('-', location_id, order_id, uid, 'PROD')`
- `LINEITEM_TYPE = 'PROD'`
- `GROSS_VALUE = CAST(gross_sales_money_amount AS BIGINT) / 100.0`
- `TAX_VALUE = CAST(total_tax_money_amount AS BIGINT) / 100.0`
- `NET_VALUE = CAST(total_money_amount AS BIGINT) / 100.0`
- `QUANTITY = CAST(quantity AS DECIMAL(18,4))`
- `HEADER_ID = CONCAT_WS('-', location_id, order_id)` — FK to CUSTORDER
- `LINEITEM_TIMESTAMP = order.created_at` (joined from DL_ORDERS)
- `ITEM_DATE = TRADING_DATE`, `ORDER_DATE = TRADING_DATE`

**Tender** → `SQR_TENDER` from `DL_ORDERS_TENDERS`
- `SRC_KEY = CONCAT_WS('-', location_id, order_id, id, 'TENDER')`
- `LINEITEM_TYPE = 'TENDER'`
- `GROSS_VALUE = CAST(amount_money_amount AS BIGINT) / 100.0`
- `TENDER_NAME = type`, `TENDER_ID = type`
- `HEADER_ID = CONCAT_WS('-', location_id, order_id)`

**Line Item Tax** → `SQR_LINEITEM_TAX` from `DL_ORDERS_LINEITEMS_TAXES`
- `SRC_KEY = CONCAT_WS('-', location_id, order_id, lineitem_uid, tax_uid, 'TAX')`
- `LINEITEM_TYPE = 'TAX'`
- `GROSS_VALUE = CAST(applied_money_amount AS BIGINT) / 100.0`
- `HEADER_ID = CONCAT_WS('-', location_id, order_id)`

**Line Item Discount** → `SQR_LINEITEM_DISCOUNT` from `DL_ORDERS_LINEITEMS_DISCOUNTS`
- `SRC_KEY = CONCAT_WS('-', location_id, order_id, lineitem_uid, discount_uid, 'DISCOUNT')`
- `LINEITEM_TYPE = 'DISCOUNT'`
- `GROSS_VALUE = CAST(applied_money_amount AS BIGINT) / -100.0` — negative value (discount reduces total)
- `HEADER_ID = CONCAT_WS('-', location_id, order_id)`

**Line Item Modifier** → `SQR_LINEITEM_MODIFIER` from `DL_ORDERS_LINEITEMS_MODIFIERS`
- `SRC_KEY = CONCAT_WS('-', location_id, order_id, lineitem_uid, uid, 'MOD')`
- `LINEITEM_TYPE = 'MOD'`
- `GROSS_VALUE = CAST(total_price_money_amount AS BIGINT) / 100.0`
- `HEADER_ID = CONCAT_WS('-', location_id, order_id)`

**Service Charge Line** → `SQR_LINEITEM_SVC` from `DL_ORDERS_SERVICECHARGES`
- `SRC_KEY = CONCAT_WS('-', location_id, order_id, uid, 'SVC')`
- `LINEITEM_TYPE = 'SVC'`
- `GROSS_VALUE = CAST(total_money_amount AS BIGINT) / 100.0`
- `HEADER_ID = CONCAT_WS('-', location_id, order_id)`

#### Inventory (2 steps)

**Inventory Item** → `SQR_INVITEM` from `DL_CATALOG_ITEMVARIATIONS`
- `ITEM_SRC_KEY = id`
- `INVITEM_NAME = item_variation_data_name`, `INVITEM_ID = id`
- `UOM = item_variation_data_measurement_unit_id` (or NULL if not set)
- `UOM_COST = NULL` — Square doesn't expose item cost via public API
- `LEVEL_NAME = 'BOTTOM'`, `PARENT_ID = item_variation_data_item_id`
- Filter: `WHERE item_variation_data_track_inventory = 'true'`

**Stock Event** → `SQR_STOCKEVENT` from `DL_INVENTORY_CHANGES`
- `SRC_KEY = CONCAT_WS('-', location_id, id)`
- `EVENT_TS = occurred_at`
- `UOM_QUANITY = CAST(quantity AS DECIMAL(18,4))`
- `INTERNAL_REF = catalog_object_id`, `EXTERNAL_REF = reference_id`
- EVENT_TYPE and EVENT_BEHAVIOUR derived by CASE:

```sql
CASE
  WHEN type = 'PHYSICAL_COUNT'                            THEN 'COUNT'
  WHEN to_state = 'IN_STOCK' AND from_state = 'NONE'     THEN 'ORDER'      -- received from vendor
  WHEN to_state = 'SOLD'                                  THEN 'SALE'
  WHEN to_state = 'WASTE'                                 THEN 'WASTE'
  WHEN to_state = 'IN_TRANSIT_TO'                         THEN 'TRANSFER'
  WHEN to_state = 'IN_STOCK' AND from_state = 'IN_TRANSIT_TO' THEN 'TRANSFER'
  WHEN to_state = 'COMPOSED'                              THEN 'PRODUCTION'
  WHEN from_state = 'COMPOSED' AND to_state = 'IN_STOCK'  THEN 'PRODUCTION'
  WHEN from_state IN ('SOLD','RETURNED_BY_CUSTOMER')
       AND to_state = 'IN_STOCK'                          THEN 'ORDER'      -- customer return
  ELSE 'ORDER'                                                              -- fallback
END AS EVENT_TYPE,

CASE
  WHEN type = 'PHYSICAL_COUNT'                            THEN 'COUNT'
  WHEN to_state IN ('SOLD','WASTE','IN_TRANSIT_TO','COMPOSED') THEN '-'
  WHEN to_state = 'IN_STOCK'                              THEN '+'
  ELSE '+'                                                                  -- fallback
END AS EVENT_BEHAVIOUR
```

#### Refunds (1 step)

**Refund** → `SQR_REFUND` from `DL_REFUNDS`
- `SRC_KEY = id`
- `REFUND_AMOUNT = CAST(amount_money_amount AS BIGINT) / 100.0`
- `REFUND_REASON = reason`, `REFUND_STATUS = status`
- `ORDER_ID = CONCAT_WS('-', location_id, order_id)` — FK to CUSTORDER
- `PAYMENT_ID = payment_id`

#### CRM (1 step)

**Customer** → `SQR_CUSTOMER` from `DL_CUSTOMERS`
- `ITEM_SRC_KEY = id`
- `FIRST_NAME = given_name`, `SURNAME = family_name`
- `EMAIL = email_address`, `PHONE = phone_number`
- `COMPANY = company_name`
- Address fields pass through for ADDRESS hub mapping
- Dedup: `ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) = 1`

#### Workforce (3 steps)

**Employee** → `SQR_EMPLOYEE` from `DL_TEAM_MEMBERS`
- `ITEM_SRC_KEY = id`
- `SURNAME = family_name`, `FIRST_NAME = given_name`, `MIDDLE_NAME = NULL`
- Dedup: `ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) = 1`

**Job** → `SQR_JOB` from `DL_SHIFTS`
- `SELECT DISTINCT wage_title`
- `ITEM_SRC_KEY = wage_title`, `JOB_NAME = wage_title`, `JOB_CODE = NULL`

**Timecard** → `SQR_TIMECARD` from `DL_SHIFTS`
- `SRC_KEY = CONCAT_WS('-', location_id, id)`
- `TRADING_DATE = CAST(start_at AS DATE)`
- `CLOCK_IN_TS = start_at`, `CLOCK_OUT_TS = end_at`
- `MINS_WORKED = DATEDIFF(MINUTE, CAST(start_at AS DATETIME2), CAST(end_at AS DATETIME2))`
- `HOURS_ADJ = NULL`, `OVERTIME_MINS = NULL`

### 3.2 Tier 2 — Link Staging (16 Steps)

| # | Step Name | Staging Table | Sources | Link Entity | Notes |
|---|---|---|---|---|---|
| 1 | Order to Location | `SQR_CUSTORDER_LOCATION` | `SQR_CUSTORDER` | CUSTORDER_LOCATION | HEADER_ID → LOCATION_ID |
| 2 | Order to Channel | `SQR_CHANNEL_CUSTORDER` | `SQR_CUSTORDER` + `SQR_CHANNEL` | CHANNEL_CUSTORDER | source_name → channel key |
| 3 | Order to Occasion | `SQR_CUSTORDER_OCCASION` | `SQR_CUSTORDER` + `DL_ORDERS_FULFILLMENTS` | CUSTORDER_OCCASION | COALESCE(fulfillment.type, 'DINE_IN') |
| 4 | Line Item to Order | `SQR_CUSTORDER_LINEITEM` | `SQR_LINEITEM` | CUSTORDER_LINEITEM | HEADER_ID → SRC_KEY |
| 5 | Line Item to Product | `SQR_LINEITEM_PRODUCT` | `SQR_LINEITEM` | LINEITEM_PRODUCT | catalog_object_id → product key |
| 6 | Line Item to Occasion | `SQR_LINEITEM_OCCASION` | `SQR_LINEITEM` + fulfillment | LINEITEM_OCCASION | Same derivation as #3 |
| 7 | Tax to Line Item | `SQR_LINEITEM_TAX_LNK` | `SQR_LINEITEM_TAX` | LINEITEM_TAX | tax SRC_KEY ↔ parent lineitem SRC_KEY |
| 8 | Discount to Line Item | `SQR_DISCOUNT_LINEITEM` | `SQR_LINEITEM_DISCOUNT` | DISCOUNT_LINEITEM | discount SRC_KEY ↔ parent lineitem SRC_KEY |
| 9 | Modifier to Line Item | `SQR_LINEITEM_MOD` | `SQR_LINEITEM_MODIFIER` | LINEITEM_MOD | modifier SRC_KEY ↔ parent lineitem SRC_KEY |
| 10 | Tender to Line Item | `SQR_LINEITEM_TENDER` | `SQR_TENDER` | LINEITEM_TENDER | tender SRC_KEY ↔ order header (distributed to line items) |
| 11 | SvcCharge to Line Item | `SQR_LINEITEM_SVC_LNK` | `SQR_LINEITEM_SVC` | LINEITEM_SVCCHARGE | svc SRC_KEY ↔ order header |
| 12 | InvItem to StockEvent | `SQR_INVITEM_STOCKEVENT` | `SQR_STOCKEVENT` | INVITEM_STOCKEVENT | catalog_object_id → INVITEM key |
| 13 | Location to StockEvent | `SQR_LOCATION_STOCKEVENT` | `SQR_STOCKEVENT` | LOCATION_STOCKEVENT | location_id → LOCATION key |
| 14 | Refund to Order | `SQR_CUSTORDER_REFUND` | `SQR_REFUND` | CUSTORDER_REFUND | ORDER_ID → CUSTORDER key |
| 15 | Employee Job Timecard | `SQR_EMP_JOB_TIMECARD` | `SQR_TIMECARD` + `SQR_EMPLOYEE` + `SQR_JOB` | EMPLOYEE_JOB_TIMECARD | Ternary: shift → team member → job |
| 16 | Order to Employee | `SQR_CUSTORDER_EMPLOYEE` | `SQR_CUSTORDER` + `DL_SHIFTS` | CUSTORDER_EMPLOYEE | Approximate: order timestamp BETWEEN shift start/end at same location |

### 3.3 Tier 3 — Self-Referencing Links (1 Step)

| # | Step Name | Staging Table | Sources | Link Entity | Notes |
|---|---|---|---|---|---|
| 1 | Modifier to Parent Line Item | `SQR_LINEITEM_LINEITEM` | `SQR_LINEITEM` + `SQR_LINEITEM_MODIFIER` | LINEITEM_LINEITEM | Links MOD-type line items back to their parent PROD-type line item via `lineitem_uid`. LABEL = modifier name, VALUE = modifier price, INFO = NULL |

---

## 4. Entity Mappings

### 4.1 Hub Mappings (25)

| # | Entity | Source Table | Business Key (hash:1) | Satellite Attributes (hash:0) |
|---|---|---|---|---|
| 1 | LOCATION | `SQR_LOCATION` | `CONCAT_WS('-', location_id)` | LOCATION_NAME, LOCATION_ID, LEVEL_NAME, PARENT_ID, BOTTOM_LEVEL, MICROSERVICE_NAME=NULL, MICROSERVICE_ID=NULL |
| 2 | PRODUCT | `SQR_PRODUCT` | `CONCAT_WS('-', catalog_id)` | PRODUCT_NAME, PRODUCT_ID, LEVEL_NAME, PARENT_ID, BOTTOM_LEVEL, MICROSERVICE_NAME=NULL, MICROSERVICE_ID=NULL |
| 3 | CHANNEL | `SQR_CHANNEL` | `CONCAT_WS('-', channel_name)` | CHANNEL_NAME, CHANNEL_ID, LEVEL_NAME, BOTTOM_LEVEL |
| 4 | OCCASION | `SQR_OCCASION` | `CONCAT_WS('-', occasion_name)` | OCCASION_NAME, OCCASSION_ID, LEVEL_NAME, PARENT_ID, BOTTOM_LEVEL |
| 5 | TAX | `SQR_TAX` | `CONCAT_WS('-', tax_id)` | TAX_NAME, TAX_ID, TAX_MULTIPLIER, LEVEL_NAME, PARENT_ID |
| 6 | DISCOUNT | `SQR_DISCOUNT` | `CONCAT_WS('-', discount_id)` | DISCOUNT_NAME, DISCOUNT_ID, VALUE_TYPE, VALUE, IS_WASTE=0, LEVEL_NAME, PARENT_ID |
| 7 | MOD | `SQR_MODIFIER` | `CONCAT_WS('-', modifier_id)` | MOD_NAME, MOD_ID, LEVEL_NAME, PARENT_ID, BOTTOM_LEVEL, MICROSERVICE_NAME=NULL, MICROSERVICE_ID=NULL |
| 8 | SVCCHARGE | `SQR_SERVICECHARGE` | `CONCAT_WS('-', svc_name)` | SVCCHARGE_NAME, SVC_ID, LEVEL_NAME, PARENT_ID |
| 9 | TENDER | `SQR_TENDER` | `CONCAT_WS('-', tender_type)` | TENDER_NAME, TENDER_ID, LEVEL_NAME, PARENT_ID |
| 10 | CUSTORDER | `SQR_CUSTORDER` | `CONCAT_WS('-', location_id, order_id)` | GRAND_TOTAL, GROSS_SALES, NET_SALES, TAX_TOTAL, DISCOUNT_GROSS, SVC_CHARGE_TOTAL, GUEST_COUNT, ITEM_COUNT, ORDER_DATE, OPEN_TIME, CLOSE_TIME, TABLE_NO=NULL, ORDER_INFO, EXTERNAL_REFERENCE, ORDER_STATUS, PAYMENT_STATUS, TRADING_DATE |
| 11 | LINEITEM | `SQR_LINEITEM` | `SRC_KEY` | HEADER_ID, LINEITEM_TYPE='PROD', GROSS_VALUE, TAX_VALUE, NET_VALUE, QUANTITY, QUANTITY_INV=NULL, LINEITEM_TIMESTAMP, ITEM_DATE, ORDER_DATE, VOID_FLAG, LINE_ID, LINE_ORDER, TRADING_DATE |
| 12 | LINEITEM | `SQR_TENDER` | `SRC_KEY` | Same schema, LINEITEM_TYPE='TENDER' |
| 13 | LINEITEM | `SQR_LINEITEM_TAX` | `SRC_KEY` | Same schema, LINEITEM_TYPE='TAX' |
| 14 | LINEITEM | `SQR_LINEITEM_DISCOUNT` | `SRC_KEY` | Same schema, LINEITEM_TYPE='DISCOUNT' |
| 15 | LINEITEM | `SQR_LINEITEM_MODIFIER` | `SRC_KEY` | Same schema, LINEITEM_TYPE='MOD' |
| 16 | LINEITEM | `SQR_LINEITEM_SVC` | `SRC_KEY` | Same schema, LINEITEM_TYPE='SVC' |
| 17 | INVITEM | `SQR_INVITEM` | `CONCAT_WS('-', catalog_variation_id)` | INVITEM_NAME, PARENT_ID, LEVEL_NAME, UOM, INVITEM_ID, UOM_COST=NULL |
| 18 | STOCKEVENT | `SQR_STOCKEVENT` | `CONCAT_WS('-', location_id, change_id)` | EVENT_TYPE, EVENT_TS, PACK_DESC=NULL, PACK_QUANTITY=NULL, UOM, UOM_QUANITY, EXTERNAL_REF, INTERNAL_REF, EVENT_BEHAVIOUR |
| 19 | REFUND | `SQR_REFUND` | `CONCAT_WS('-', refund_id)` | Per REFUND entity definition in DataVaultEntities |
| 20 | INDIVIDUAL | `SQR_CUSTOMER` | `CONCAT_WS('-', customer_id)` | Per INDIVIDUAL entity definition |
| 21 | ADDRESS | `SQR_CUSTOMER` | `CONCAT_WS('-', customer_id, 'HOME')` | Address fields from customer record |
| 22 | CONTACT | `SQR_CUSTOMER` | `CONCAT_WS('-', customer_id, 'EMAIL')` | Email contact row |
| 23 | CONTACT | `SQR_CUSTOMER` | `CONCAT_WS('-', customer_id, 'PHONE')` | Phone contact row (separate mapping or handled in staging with UNION) |
| 24 | EMPLOYEE | `SQR_EMPLOYEE` | `CONCAT_WS('-', team_member_id)` | SURNAME, FIRST_NAME, MIDDLE_NAME=NULL |
| 25 | JOB | `SQR_JOB` | `CONCAT_WS('-', job_name)` | JOB_NAME, JOB_CODE=NULL |
| 26 | TIMECARD | `SQR_TIMECARD` | `CONCAT_WS('-', location_id, shift_id)` | TRADING_DATE, CLOCK_IN_TS, CLOCK_OUT_TS, MINS_WORKED, HOURS_ADJ=NULL, OVERTIME_MINS=NULL |

*Note: 26 rows due to CONTACT having two mapping patterns (EMAIL + PHONE). Counted as 25 unique entity names.*

### 4.2 Link Mappings (19)

| # | Entity | Source Table | Hub Keys (all hash:1) | SAT_LNK Attrs | type2_columns |
|---|---|---|---|---|---|
| 1 | CUSTORDER_LOCATION | `SQR_CUSTORDER_LOCATION` | CUSTORDER_HUB_ID, LOCATION_HUB_ID | — | — |
| 2 | CUSTORDER_OCCASION | `SQR_CUSTORDER_OCCASION` | CUSTORDER_HUB_ID, OCCASION_HUB_ID | — | — |
| 3 | CHANNEL_CUSTORDER | `SQR_CHANNEL_CUSTORDER` | CHANNEL_HUB_ID, CUSTORDER_HUB_ID | — | — |
| 4 | CUSTORDER_LINEITEM | `SQR_CUSTORDER_LINEITEM` | CUSTORDER_HUB_ID, LINEITEM_HUB_ID | — | — |
| 5 | LINEITEM_PRODUCT | `SQR_LINEITEM_PRODUCT` | LINEITEM_HUB_ID, PRODUCT_HUB_ID | — | — |
| 6 | LINEITEM_OCCASION | `SQR_LINEITEM_OCCASION` | LINEITEM_HUB_ID, OCCASION_HUB_ID | — | — |
| 7 | LINEITEM_TAX | `SQR_LINEITEM_TAX_LNK` | LINEITEM_HUB_ID, TAX_HUB_ID | — | — |
| 8 | DISCOUNT_LINEITEM | `SQR_DISCOUNT_LINEITEM` | DISCOUNT_HUB_ID, LINEITEM_HUB_ID | — | — |
| 9 | LINEITEM_MOD | `SQR_LINEITEM_MOD` | LINEITEM_HUB_ID, MOD_HUB_ID | — | — |
| 10 | LINEITEM_TENDER | `SQR_LINEITEM_TENDER` | LINEITEM_HUB_ID, TENDER_HUB_ID | — | — |
| 11 | LINEITEM_SVCCHARGE | `SQR_LINEITEM_SVC_LNK` | LINEITEM_HUB_ID, SVCCHARGE_HUB_ID | — | — |
| 12 | LINEITEM_LINEITEM | `SQR_LINEITEM_LINEITEM` | LINEITEM_HUB_ID (parent), LINEITEM_HUB_ID (child) | LABEL, VALUE, INFO | — |
| 13 | INVITEM_STOCKEVENT | `SQR_INVITEM_STOCKEVENT` | INVITEM_HUB_ID, STOCKEVENT_HUB_ID | — | — |
| 14 | LOCATION_STOCKEVENT | `SQR_LOCATION_STOCKEVENT` | LOCATION_HUB_ID, STOCKEVENT_HUB_ID | — | — |
| 15 | CUSTORDER_REFUND | `SQR_CUSTORDER_REFUND` | CUSTORDER_HUB_ID, REFUND_HUB_ID | — | — |
| 16 | ADDRESS_INDIVIDUAL | `SQR_CUSTOMER` | ADDRESS_HUB_ID, INDIVIDUAL_HUB_ID | — | — |
| 17 | CONTACT_INDIVIDUAL | `SQR_CUSTOMER` | CONTACT_HUB_ID, INDIVIDUAL_HUB_ID | — | — |
| 18 | EMPLOYEE_JOB_TIMECARD | `SQR_EMP_JOB_TIMECARD` | EMPLOYEE_HUB_ID, JOB_HUB_ID, TIMECARD_HUB_ID | — | — |
| 19 | CUSTORDER_EMPLOYEE | `SQR_CUSTORDER_EMPLOYEE` | CUSTORDER_HUB_ID, EMPLOYEE_HUB_ID | — | — |

### 4.3 Totals

- **Hub mappings:** 26 rows (25 unique entity names — CONTACT has 2 source patterns)
- **Link mappings:** 19
- **Total:** 45 entity mapping records

---

## 5. Presentation Layer Impact Assessment

### 5.1 Tables That Receive Square Data Automatically

No presentation table DDL or PresentationControl changes required.

**POS (immediate):**

| Table | Tier | Impact |
|---|---|---|
| D_PRODUCT | 1 | Square Category→Item→Variation fills BOTTOM/MIDDLE_1/TOP hierarchy |
| D_LOCATION | 1 | Square locations populate dimension |
| D_CHANNEL | 1 | Square order sources (POS, ONLINE, APP) appear as new channels |
| D_OCCASION | 1 | Square fulfillment types (DINE_IN, PICKUP, DELIVERY) appear as occasions |
| D_TAX | 1 | Square catalog taxes populate dimension |
| D_DISCOUNT | 1 | Square catalog discounts populate dimension |
| D_MOD | 1 | Square modifiers populate 2-level hierarchy |
| D_SERVICECHARGE | 1 | Square service charges populate dimension |
| D_TENDER | 1 | **First integration to populate** — fixes H5 gap |
| CALENDAR | 1 | No impact (independently populated) |
| F_LINEITEM_15MIN | 2 | Core POS fact — Square line items join all 10 dimension links |
| F_PRODUCT_MARGIN_DAY | 2 | Revenue columns populated; NET_COST = NULL (see gaps) |
| E_COOCCUR_BASE | 2 | Co-occurrence analysis works automatically |
| D_COOCCURRENCE | 2 | Built from E_COOCCUR_BASE |
| FORECAST_ACTUALS_BASE | 2 | Square sales feed forecasting feature table |

**Inventory (when present):**

| Table | Tier | Impact |
|---|---|---|
| D_INVITEM | 1 | Square tracked items populate dimension |
| F_INV_COUNTS_DAY | 2 | COUNT + SALE events populate stock counts |
| F_INV_USAGE_DAY | 2 | ORDER/WASTE/TRANSFER/SALE movement columns |
| F_INV_SALES_DAY | 2 | Cross-domain bridge works without XMSE-949 product matching issue for Square-only orgs |

### 5.2 Visualisation Queries — No Changes

All 109 existing vis queries read from presentation tables and work unchanged. Square data appears in dashboards automatically.

### 5.3 Known Gaps

| Gap | Impact | When to Address |
|---|---|---|
| F_PRODUCT_MARGIN_DAY NET_COST = NULL | Margin analytics show revenue but no cost/margin % | When LOCATION_OCCASION_PRODUCT mapping added, or if Square exposes cost data |
| DimCustomer not connected to DV CRM entities | Customer data lands in DV hubs but no PresentationControl step bridges to DimCustomer | When a CRM dashboard is designed |
| EMPLOYEE_LINEITEM not mapped | Per-item employee attribution unavailable | Square doesn't support this natively |
| DEAL entity not mapped | Deal/combo analytics unavailable | Square promotions work via discounts; map to DEAL if a Square combo pattern is identified |

---

## 6. Implementation Notes

### 6.1 Currency Conversion

Square stores monetary values as integers in smallest currency unit (pence for GBP, cents for USD). All Tier 1 staging steps divide by 100:

```sql
CAST(total_money_amount AS BIGINT) / 100.0 AS GRAND_TOTAL
```

Hardcoding `/100.0` is safe for GBP/USD/EUR — the only currencies current XMS BI clients use.

### 6.2 Quantity String Casting

Square quantities are strings. Staging must CAST:

```sql
CAST(quantity AS DECIMAL(18,4)) AS QUANTITY
```

### 6.3 TRADING_DATE Derivation

Square has no explicit "date of business" field. Derived from order close time:

```sql
CAST(COALESCE(closed_at, created_at) AS DATE) AS TRADING_DATE
```

For v1 this assumes UTC = local date (valid for UK clients). Multi-timezone support would require a timezone lookup join using `DL_LOCATIONS.timezone`.

### 6.4 Occasion Default

Orders without fulfillment records (walk-in counter sales) get `'DINE_IN'` as default occasion:

```sql
COALESCE(f.type, 'DINE_IN') AS OCCASION_NAME
```

### 6.5 Soft-Deleted Catalog Objects

Square soft-deletes catalog objects. Dimension staging filters them out:

```sql
WHERE is_deleted = 'false' OR is_deleted IS NULL
```

### 6.6 CUSTORDER_EMPLOYEE Approximate Join

Square has no direct order→employee field. The link is derived by matching order timestamps to shift windows:

```sql
SELECT DISTINCT
    o.HEADER_ID, o.LOCATION_ID, s.team_member_id
FROM SQR_CUSTORDER o
JOIN DL_SHIFTS s
    ON o.LOCATION_ID = s.location_id
    AND CAST(o.ORDER_DATE AS DATETIME2)
        BETWEEN CAST(s.start_at AS DATETIME2) AND CAST(s.end_at AS DATETIME2)
    AND s.status = 'OPEN'
```

Multiple employees per order is expected and correct.

### 6.7 StockEvent State Transition Mapping

Square inventory uses state transitions (`from_state` → `to_state`). Full mapping in Section 3.1 (Stock Event staging step).

### 6.8 Incremental Fetch Watermarks (for Fetcher Team)

| Endpoint | Watermark Field | Notes |
|---|---|---|
| SearchOrders | `updated_at` in date_time_filter | Sort by UPDATED_AT |
| SearchCatalogObjects | `begin_time` parameter | Objects modified after this time |
| BatchRetrieveInventoryCounts | `updated_after` parameter | Filter by calculated_at |
| BatchRetrieveInventoryChanges | `updated_after` + `updated_before` | Time window |
| ListPaymentRefunds | `updated_at_begin_time` | Delta on refund updates |
| SearchCustomers | Cursor + sort by updated_at | No native time filter |
| SearchTeamMembers | Cursor-based | Full refresh recommended |
| SearchShifts | `start.start_at` + `start.end_at` | Time range filter |

---

## 7. Script File Inventory

| File | Estimated Lines | Contents |
|---|---|---|
| `Square/Square001_INIT.sql` | ~50 | AddIntegration + UPDATE IntegrationType + APIEndpointDetail JSON skeleton |
| `Square/Square001_DDL.sql` | ~600 | 22 DL table CREATE TABLE DDLs as GlobalParameters STAGE_DDL records |
| `Square/Square001_Staging.sql` | ~2,500-3,000 | 39 StagingControl upserts with full query_sql |
| `Square/Square001_Mapping.sql` | ~1,500 | 45 EntityMappings upserts with source_columns/entity_columns JSON |
| `Square/Square001_Final.sql` | ~10 | `EXEC [core].[UploadEntityMappings] @intSchema = N'int_square001'` |

**Estimated total: ~4,700-5,200 lines across 5 files**

### Deployment Order

1. `Square001_INIT.sql` — registers integration
2. `sp_CreateIntegrationTables @DatabaseName = 'core', @SchemaName = 'int_square001'` — creates StagingControl, EntityMappings, GlobalParameters tables
3. `Square001_DDL.sql` — DL table definitions into GlobalParameters
4. `Square001_Staging.sql` — staging steps into StagingControl
5. `Square001_Mapping.sql` — entity mappings into EntityMappings
6. `Square001_Final.sql` — generates Load steps from entity mappings

Per-org activation: `EXEC [core].[MapOrganisationToIntegration] @OrganisationID = ?, @IntegrationID = ?` — triggers schema provisioning and DL table creation in the org database.

---

## 8. Square API Reference Summary

Documented here for context. Not part of the implementation scope.

### Authentication
- OAuth 2.0 Code Flow (server-side)
- Access token: 30-day expiry, refresh token: never expires
- Required scopes: `ORDERS_READ`, `PAYMENTS_READ`, `ITEMS_READ`, `INVENTORY_READ`, `MERCHANT_PROFILE_READ`, `EMPLOYEES_READ`

### Rate Limits
- Not publicly disclosed; recommended 1-5 req/s starting point
- HTTP 429 on limit exceeded; exponential backoff with jitter
- Response headers: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`

### Pagination
- Cursor-based everywhere; cursors expire after 5 minutes
- Page sizes: Orders 500, Catalog 1000, Inventory 1000, Payments 100

### Webhooks (optional, for near-real-time sync)
- `order.created`, `order.updated`
- `payment.created`, `payment.updated`
- `catalog.version.updated`
- `inventory.count.updated`
- `customer.created`, `customer.updated`
- Retry: exponential backoff, up to 11 attempts over 24 hours
- `event_id` for idempotent deduplication
