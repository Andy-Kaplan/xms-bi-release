# Growyze Integration — Staging & Entity Mapping Design

**Date:** 2026-03-05
**Status:** Approved
**Database:** 20251208_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14 (GrowyzeDev, OrgID 9)
**Integration:** Growyze001, schema `int_growyze001`, IntegrationID 5, Type INVENTORY

## 1. Overview

Design for building StagingControl and EntityMappings records for the Growyze integration, using MarketMan as the template. Growyze is an inventory management platform that provides data on products, recipes, dishes (menu items), orders, delivery notes, invoices, sales, and waste. This design covers Phase 1 — all entities except INVREPORT (no Growyze equivalent) and INVOICE (deferred to Phase 2).

### DL Table Inventory (10 tables)

| DL Table | Rows | Distinct Keys | Grain | Business Key |
|---|---|---|---|---|
| DL_ORGANIZATIONS | 9 | 7 orgs | 1 per org (dupes from subOrgIds explosion) | `id` |
| DL_PRODUCTS | 3,450 | 3,346 products | 1 per product (104 dupes from multi-fetch) | `id` |
| DL_RECIPES | 3,034 | 119 recipes | Pre-exploded: 1 per ingredient line (~25x fanout) | `id` (recipe level) |
| DL_DISHES | 4,838 | 2,158 dishes | Pre-exploded: 1 per component line (2.2x fanout) | `id` (dish level) |
| DL_ORDERS | 1,503 | 383 orders | Pre-exploded: 1 per order line item | `id` (order level) |
| DL_INVOICES | 1,306 | 272 invoices | Pre-exploded: 1 per invoice product line | `id` — **DEFERRED** |
| DL_DELIVERYNOTES | 1,349 | 275 DNs | Pre-exploded: 1 per DN product line | `id` (DN level) |
| DL_SALES | 2,380 | 2,380 sales | 1 per sale (clean, no dupes) | `id` |
| DL_SALESDETAIL | 3,397 | 3,397 lines | 1 per line item (clean) | `id` + `items_posId` |
| DL_WASTES | 432 | 87 waste records | Triple-nested explosion (report x product x day, 5x fanout) | `products_wastesPerDay_id` |

**Key characteristic:** 7 of 10 tables are pre-exploded by the Growyze API (nested JSON arrays flattened into rows). Every staging step requires ROW_NUMBER dedup or DISTINCT to extract hub-level records.

## 2. Design Decisions

| # | Decision | Choice | Rationale |
|---|---|---|---|
| D1 | DL_PRODUCTS entity target | HUB_INVITEM | Inventory items (ingredients/supplies), not POS products |
| D2 | DL_DISHES entity target | HUB_PRODUCT | Menu items sold at POS |
| D3 | PRODUCT hub key | Dish `id` (MongoDB ObjectId) | `posId` unreliable in inventory systems (requires secondary config step); captured as SAT attr |
| D4 | DL_DELIVERYNOTES role | STOCKEVENT (EVENT_TYPE='DELIVERY', EVENT_BEHAVIOUR='+') | Trusted source for actual received quantities (not DL_ORDERS which is what was ordered) |
| D5 | DL_INVOICES | Deferred (Phase 2) | No existing DV hub entity; AP workflow doc; no product ID column (only barcode/code/name) |
| D6 | INVREPORT | Skipped entirely | No Growyze equivalent (MarketMan-specific actual_vs_theo API) |
| D7 | DISTRIBUTOR hub | Sentinel (-999) | Growyze has no distributor concept separate from supplier |
| D8 | OCCASION hub | Sentinel (-999) + 1-row staging step | No occasion/daypart data in Growyze |
| D9 | INVITEM hierarchy | 3-tier UNION (product -> subCategory -> category) | 7 categories, 24 subCategories. Faithful representation of source hierarchy |
| D10 | PRODUCT hierarchy | 2-tier UNION (dish -> category) | Source only provides 1 parent tier (4 categories: Food, Beverages, Other, Retail) |
| D11 | UOM conversion | `core.reference.UOM_CONVERSION` table | Shared, integration-agnostic; handles portion + volume + weight conversions |
| D12 | Sales depletion | Full conversion via UOM table; no exclusions for unit mismatches | Two-part UNION: direct ingredients + sub-recipe ingredients with yield scaling |
| D13 | Sales-to-Dish join | posId + organizations lookup (91.6% match) | Unmatched 8.4% = non-recipe items (rentals, equipment), still flow to LINEITEM/CUSTORDER |

## 3. Entity Mapping Summary

### 3.1 Hub Mappings (8)

| Entity | Source Stage | Key Column | Satellite Attributes |
|---|---|---|---|
| INVITEM | GRYZ_INVITEMS | `id` | INVITEM_NAME, PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL, UOM, ATTR_1..5, MICROSERVICE_ID, INVITEM_ID, MICROSERVICE_NAME |
| LOCATION | GRYZ_LOCATION | `id` | LOCATION_NAME, PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL, MICROSERVICE_ID, LOCATION_ID, MICROSERVICE_NAME |
| SUPPLIER | GRYZ_SUPPLIERS | `supplier_id` | SUPPLIER_NAME, MICROSERVICE_ID, SUPPLIER_ID, MICROSERVICE_NAME |
| PRODUCT | GRYZ_PRODUCT | dish `id` | PRODUCT_NAME, PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL, PRODUCT_ID, MICROSERVICE_ID, MICROSERVICE_NAME (posId stored as ATTR_1) |
| STOCKORDER | GRYZ_STOCKORDER | order `id` | ORDER_DATE, DELIVERY_DATE, ORDER_TOTAL, ORDER_TAX, ORDER_INFO, ORDER_STATUS |
| STOCKEVENT | GRYZ_STOCKEVENT | SRC_KEY | EVENT_TYPE, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, UOM_QUANITY, EXTERNAL_REF, INTERNAL_REF, EVENT_BEHAVIOUR |
| CUSTORDER | GRYZ_LINEITEM | sale `id` (HEADER_ID) | NET_SALES, ITEM_COUNT, OPEN_TIME, CLOSE_TIME, ORDER_DATE, TRADING_DATE, EXTERNAL_REFERENCE |
| LINEITEM | GRYZ_LINEITEM | SRC_KEY | HEADER_ID, LINEITEM_TYPE, QUANTITY, NET_VALUE, GROSS_VALUE, ORDER_DATE, TRADING_DATE |

### 3.2 Link Mappings (14)

| Entity | Source Stage | Hub References | SAT_LNK Attrs | Type2 |
|---|---|---|---|---|
| CUSTORDER_LINEITEM | GRYZ_LINEITEM | LINEITEM + CUSTORDER | — | — |
| CUSTORDER_LOCATION | GRYZ_LINEITEM | CUSTORDER + LOCATION | — | — |
| CUSTORDER_OCCASION | GRYZ_LINEITEM | CUSTORDER + OCCASION (sentinel) | — | — |
| LINEITEM_PRODUCT | GRYZ_LINEITEM | LINEITEM + PRODUCT (dish_id via posId lookup) | — | — |
| LINEITEM_OCCASION | GRYZ_LINEITEM | LINEITEM + OCCASION (sentinel) | — | — |
| INVITEM_INVITEM | GRYZ_PREP_RECIPES | PARENT_INVITEM + CHILD_INVITEM | UOM, UOM_VALUE | — |
| INVITEM_STOCKEVENT | GRYZ_STOCKEVENT | INVITEM + STOCKEVENT | — | — |
| INVITEM_STOCKORDER | GRYZ_ORDER_ITEMS | INVITEM + STOCKORDER | qty, price, case info | — |
| LOCATION_STOCKEVENT | GRYZ_STOCKEVENT | LOCATION + STOCKEVENT | — | — |
| STOCKEVENT_STOCKORDER | GRYZ_STOCKEVENT (DELIVERY type) | STOCKEVENT + STOCKORDER (via PO -> order lookup) | — | — |
| DISTRIBUTOR_STOCKORDER_SUPPLIER | GRYZ_STOCKORDER | DISTRIBUTOR(sentinel) + STOCKORDER + SUPPLIER | — | — |
| INVITEM_LOCATION_OCCASION_PRODUCT | GRYZ_PRODUCT_INVITEM | INVITEM + LOCATION + OCCASION(sentinel) + PRODUCT | UOM, UOM_VALUE | — |
| INVITEM_OCCASION_PRODUCT | GRYZ_PRODUCT_INVITEM | INVITEM + OCCASION(sentinel) + PRODUCT | UOM, UOM_VALUE | — |
| LOCATION_OCCASION_PRODUCT | GRYZ_PRODUCT | LOCATION + OCCASION(sentinel) + PRODUCT | PRODUCT_ID, NET_PRICE, NET_COST | NET_PRICE, NET_COST |

## 4. Staging Steps (14 total)

### 4.1 Tier 1 — Direct DL Table Extractions (11 steps)

#### Step 1: GRYZ_LOCATION (DL_ORGANIZATIONS)
- **Source:** DL_ORGANIZATIONS
- **Key:** `id`
- **Dedup:** ROW_NUMBER PARTITION BY id ORDER BY LOADTS_UTC DESC (9 rows -> 7)
- **Output columns:** HUB_ID key=id, LOCATION_NAME=companyName, LOCATION_ID=id, LEVEL_NAME='Location', BOTTOM_LEVEL=1, PARENT_ID=NULL, MICROSERVICE_NAME='growyze'
- **Notes:** Growyze organization = business location. Type column (MAIN/SUB/DEMO) stored as ATTR_1.

#### Step 2: GRYZ_INVITEMS (DL_PRODUCTS, 3-tier UNION)
- **Source:** DL_PRODUCTS
- **Dedup:** ROW_NUMBER PARTITION BY id ORDER BY LOADTS_UTC DESC on base (3,450 -> 3,346)
- **UNION structure:**
  - BOTTOM (products): LEVEL_NAME='Inventory Item', BOTTOM_LEVEL=1, PARENT_ID=CONCAT(organizations, '-', subCategory), key=id
  - MIDDLE_1 (subCategories): LEVEL_NAME='Sub Category', BOTTOM_LEVEL=0, PARENT_ID=category, key=CONCAT(organizations, '-', subCategory). SELECT DISTINCT.
  - TOP (categories): LEVEL_NAME='Category', BOTTOM_LEVEL=0, PARENT_ID=NULL, key=category. SELECT DISTINCT.
- **SAT attrs:** INVITEM_NAME=name, UOM=measure, ATTR_1=barcode, ATTR_2=code, ATTR_3=unit, ATTR_4=size, ATTR_5=price, MICROSERVICE_NAME='growyze'

#### Step 3: GRYZ_SUPPLIERS (DL_PRODUCTS + DL_ORDERS)
- **Source:** UNION of DISTINCT supplier_id/supplierName from DL_PRODUCTS and DISTINCT supplier_id/supplier_name from DL_ORDERS
- **Key:** `supplier_id`
- **Output:** SUPPLIER_NAME=COALESCE(supplierName, supplier_name), SUPPLIER_ID=supplier_id, MICROSERVICE_NAME='growyze'
- **Notes:** 87 distinct suppliers across both sources. DL_PRODUCTS.supplierName is mostly NULL; DL_ORDERS.supplier_name is reliable.

#### Step 4: GRYZ_OCCASION (literal sentinel)
- **Source:** Literal VALUES row
- **Key:** `'-999'`
- **Output:** 1 row — OCCASION_NAME='Unknown', LEVEL_NAME='Occasion', BOTTOM_LEVEL=1, OCCASSION_ID='-999' (note: typo is baked into platform)

#### Step 5: GRYZ_PREP_RECIPES (DL_RECIPES)
- **Source:** DL_RECIPES WHERE sections_elements_type = 'INGREDIENT' AND sections_elements_ingredient_product_id IS NOT NULL
- **Dedup:** DISTINCT on (id, sections_elements_ingredient_product_id, sections_name) — collapses 25x multi-fetch inflation
- **Output columns:** PARENT_HUB_ID=recipe id, CHILD_HUB_ID=sections_elements_ingredient_product_id, UOM=sections_elements_ingredient_measure, UOM_VALUE=sections_elements_ingredient_usedQty
- **Notes:** Links recipe (as parent INVITEM) to ingredient products (as child INVITEMs). The recipe id must also appear in GRYZ_INVITEMS as an INVITEM hub record — add recipe-level rows to GRYZ_INVITEMS UNION (LEVEL_NAME='Recipe', BOTTOM_LEVEL=1).

#### Step 6: GRYZ_PRODUCT (DL_DISHES, 2-tier UNION)
- **Source:** DL_DISHES
- **Dedup:** ROW_NUMBER PARTITION BY id ORDER BY LOADTS_UTC DESC on base (4,838 -> 2,158)
- **UNION structure:**
  - BOTTOM (dishes): LEVEL_NAME='Product', BOTTOM_LEVEL=1, PARENT_ID=category, key=id. posId stored as ATTR_1.
  - TOP (categories): LEVEL_NAME='Category', BOTTOM_LEVEL=0, PARENT_ID=NULL, key=category. SELECT DISTINCT.
- **SAT attrs:** PRODUCT_NAME=name, PRODUCT_ID=id, ATTR_1=posId, ATTR_2=barcode, MICROSERVICE_NAME='growyze'
- **Additional output for LOCATION_OCCASION_PRODUCT link:** organizations (LOCATION key), OCC_ID='-999', salePrice (NET_PRICE), totalCost (NET_COST)

#### Step 7: GRYZ_STOCKORDER (DL_ORDERS)
- **Source:** DL_ORDERS
- **Dedup:** ROW_NUMBER PARTITION BY id ORDER BY LOADTS_UTC DESC, then GROUP BY id to collapse line items to 1 row per order (1,503 -> 383)
- **Key:** order `id`
- **Output:** ORDER_DATE=placedDate, DELIVERY_DATE=expectedDeliveryDate, ORDER_TOTAL=totalCost, ORDER_TAX=NULL (not available), ORDER_INFO=po, ORDER_STATUS=status
- **Additional output for DISTRIBUTOR_STOCKORDER_SUPPLIER link:** DISTRIBUTOR_KEY='-999' (sentinel), SUPPLIER_KEY=supplier_id

#### Step 8: GRYZ_ORDER_ITEMS (DL_ORDERS)
- **Source:** DL_ORDERS (line-level)
- **Dedup:** ROW_NUMBER PARTITION BY id, items_productId ORDER BY LOADTS_UTC DESC
- **Key:** CONCAT_WS('-', id, items_productId) — unique per order line
- **Output:** OrderNumber=id (STOCKORDER key), ItemId=items_productId (INVITEM key)
- **SAT_LNK attrs:** items_quantity, items_price, items_estimatedCost, items_orderInCase, items_productCase_size, items_productCase_price

#### Step 9: GRYZ_LINEITEM (DL_SALES + DL_SALESDETAIL + DL_DISHES)
- **Source:** DL_SALESDETAIL sd LEFT JOIN (deduped DL_DISHES by posId+organizations) d
- **Key (LINEITEM):** SRC_KEY = CONCAT_WS('-', sd.id, sd.items_posId)
- **Key (CUSTORDER):** HEADER_ID = sd.id
- **Dish lookup:** ROW_NUMBER PARTITION BY posId, organizations ORDER BY createdAt DESC on DL_DISHES subquery, rn=1
- **CUSTORDER attrs (from DL_SALES join):** NET_SALES=totalSales, ITEM_COUNT=count of detail rows, OPEN_TIME=from, CLOSE_TIME=to, ORDER_DATE=from, TRADING_DATE=from (date portion), EXTERNAL_REFERENCE=metadata_orderId
- **LINEITEM attrs:** LINEITEM_TYPE='PROD', QUANTITY=items_soldQty, NET_VALUE=items_totalValue, GROSS_VALUE=items_totalValue, ORDER_DATE=from, TRADING_DATE=from
- **PRODUCT link:** PRODUCT_KEY = d.id (resolved dish_id from posId lookup). NULL for 8.4% unmatched.
- **LOCATION link:** LOCATION_KEY = sd.organizations
- **OCCASION link:** OCC_ID = '-999' (sentinel)

#### Step 10: GRYZ_DN_EVENTS (DL_DELIVERYNOTES + DL_PRODUCTS)
- **Source:** DL_DELIVERYNOTES dn INNER JOIN (deduped DL_PRODUCTS by barcode+organizations) p ON dn.products_barcode = p.barcode AND dn.organizations = p.organizations
- **Product dedup:** ROW_NUMBER PARTITION BY barcode, organizations ORDER BY id on DL_PRODUCTS subquery (handles 4 duplicate barcodes affecting 30 lines)
- **Key:** SRC_KEY = CONCAT_WS('-', dn.id, p.id)
- **Output (STOCKEVENT-compatible):** EVENT_TYPE='DELIVERY', EVENT_BEHAVIOUR='+', EVENT_TS=deliveryDate, UOM_QUANTITY=products_receivedQty, UOM=products_measure, PACK_DESC=CONCAT_WS(' ', products_size, products_unit), PACK_QUANTITY=products_receivedQtyInCase, EXTERNAL_REF=po, INTERNAL_REF=dn.id, itemId=p.id, storeID=organizations
- **STOCKEVENT_STOCKORDER link data:** PO -> order id lookup (org-scoped). 100% match rate for DNs with POs.
- **Match rate:** 99.7% (4 unmatched lines)

#### Step 11: GRYZ_WASTE_EVENTS (DL_WASTES + DL_PRODUCTS)
- **Source:** DL_WASTES w LEFT JOIN DL_PRODUCTS p ON w.products_product_name = p.name AND w.organizations = p.organizations
- **Dedup:** ROW_NUMBER PARTITION BY products_wastesPerDay_id ORDER BY LOADTS_UTC on DL_WASTES (432 -> 87 rows)
- **Product resolution:** COALESCE(w.products_product_id, p.id) — direct ID where available, name-based resolution for dish-based waste (96.6% total coverage)
- **Key:** SRC_KEY = products_wastesPerDay_id
- **Output (STOCKEVENT-compatible):** EVENT_TYPE='WASTE', EVENT_BEHAVIOUR='-', EVENT_TS=products_wastesPerDay_timeOfRecord, UOM_QUANTITY=products_wastesPerDay_totalQty, UOM=COALESCE(products_wastesPerDay_wasteMeasure, p.measure), PACK_DESC=NULL, PACK_QUANTITY=1, EXTERNAL_REF=products_wastesPerDay_dishName, INTERNAL_REF=w.id, itemId=resolved product id, storeID=organizations

### 4.2 Tier 2 — Cross-Stage Consolidation (2 steps)

#### Step 12: GRYZ_SALES (DL_SALESDETAIL + DL_DISHES + DL_RECIPES + core.reference.UOM_CONVERSION)
- **Purpose:** Calculate INVITEM depletion from sales. When a dish is sold, the underlying recipe ingredients are consumed. Produces STOCKEVENT-compatible rows with EVENT_TYPE='SALE', EVENT_BEHAVIOUR='-'.
- **Two-part UNION ALL:**

**Part A — Direct Ingredients:**
DL_SALESDETAIL sd JOIN (deduped DL_DISHES WHERE type='INGREDIENT') d ON sd.items_posId = d.posId AND sd.organizations = d.organizations
- SRC_KEY = CONCAT_WS('-', product_id, organizations, sd.id, sd.from)
- UOM_QUANTITY = CAST(items_soldQty) * CAST(ingredient_usedQty)
- itemId = sections_elements_ingredient_product_id
- UOM = sections_elements_ingredient_measure

**Part B — Sub-Recipe Ingredients (with UOM conversion):**
DL_SALESDETAIL sd JOIN (deduped DL_DISHES WHERE type='RECIPE') d JOIN (deduped DL_RECIPES WHERE type='INGREDIENT') r ON d.recipe_id = r.id LEFT JOIN core.reference.UOM_CONVERSION uom_dish ON dish_recipe_measure = uom_dish.FROM_UOM LEFT JOIN core.reference.UOM_CONVERSION uom_yield ON recipe_yield_measure = uom_yield.FROM_UOM AND uom_yield.UOM_CATEGORY = uom_dish.UOM_CATEGORY

**Depletion formula (standard units):**
```
UOM_QUANTITY = items_soldQty
    * (dish_recipe_usedQty * COALESCE(uom_dish.CONVERSION_FACTOR, 1)
       / NULLIF(recipe_yield_size * COALESCE(uom_yield.CONVERSION_FACTOR, 1), 0))
    * ingredient_usedQty
```

**Portion handling:** When dish_recipe_measure = 'portion', use recipe portionCount instead of UOM conversion:
```
UOM_QUANTITY = items_soldQty * (dish_recipe_usedQty / recipe_portionCount) * ingredient_usedQty
```

- **Output:** Same 12-column STOCKEVENT schema
- **Exclusions:** Zero soldQty lines, OTHER_INGREDIENT type (no product_id)

#### Step 13: GRYZ_STOCKEVENT (UNION ALL consolidation)
- **Source:** GRYZ_DN_EVENTS UNION ALL GRYZ_WASTE_EVENTS UNION ALL GRYZ_SALES
- **Dedup:** ROW_NUMBER OVER (PARTITION BY SRC_KEY, EVENT_BEHANIOUR ORDER BY EVENT_TS DESC) = 1
- **Output (12 columns):** SRC_KEY, EVENT_TYPE, EVENT_TS, PACK_DESC, PACK_QUANTITY, UOM, UOM_QUANTITY, EXTERNAL_REF, INTERNAL_REF, EVENT_BEHANIOUR, itemId, storeID
- **Note:** Column name `EVENT_BEHANIOUR` preserves existing platform typo for compatibility

### 4.3 Tier 3 — Requires Tier 1 + 2 Complete (1 step)

#### Step 14: GRYZ_PRODUCT_INVITEM (DL_DISHES + DL_RECIPES + DL_PRODUCTS)
- **Purpose:** Build the 4-way INVITEM_LOCATION_OCCASION_PRODUCT link connecting POS menu items (PRODUCT) to their inventory ingredients (INVITEM) at a location.
- **Two-path UNION ALL:**

**Path A — Direct Ingredients (INGREDIENT rows from DL_DISHES):**
- PRODUCT_KEY = dish id
- INVITEM_KEY = sections_elements_ingredient_product_id
- LOCATION_KEY = organizations
- OCCASION_KEY = '-999'
- UOM = sections_elements_ingredient_measure
- UOM_VALUE = sections_elements_ingredient_usedQty

**Path B — Recipe-Exploded Ingredients (RECIPE rows from DL_DISHES -> DL_RECIPES -> products):**
- DL_DISHES WHERE type='RECIPE' JOIN DL_RECIPES WHERE type='INGREDIENT' ON dish.recipe_id = recipe.id
- PRODUCT_KEY = dish id
- INVITEM_KEY = recipe.sections_elements_ingredient_product_id
- LOCATION_KEY = dish.organizations
- OCCASION_KEY = '-999'
- UOM = recipe ingredient measure
- UOM_VALUE = recipe ingredient usedQty (per batch, not per portion — presentation layer handles scaling)

**Without Path B, ~15% of dish-to-ingredient mappings are silently lost** (335 recipe-type dish rows with POS IDs).

- **Dedup:** DISTINCT on (PRODUCT_KEY, INVITEM_KEY, LOCATION_KEY, OCCASION_KEY)
- **Also sources:** INVITEM_OCCASION_PRODUCT (3-way subset of same data)

## 5. Infrastructure

### 5.1 UOM Conversion Table

**Location:** `core.reference.UOM_CONVERSION`
**Prerequisite:** CREATE SCHEMA [reference] in core database

**Schema:**
```sql
CREATE TABLE [reference].[UOM_CONVERSION] (
    FROM_UOM          NVARCHAR(50)    NOT NULL,
    TO_UOM            NVARCHAR(50)    NOT NULL,
    CONVERSION_FACTOR DECIMAL(18,10)  NOT NULL,
    UOM_CATEGORY      NVARCHAR(20)    NOT NULL,  -- VOLUME, WEIGHT, COUNT, SPECIAL
    IS_STANDARD       BIT             NOT NULL DEFAULT 0,
    NOTES             NVARCHAR(200)   NULL,
    CONSTRAINT PK_UOM_CONVERSION PRIMARY KEY (FROM_UOM, TO_UOM)
);
```

**Seed data (14 records):**

| FROM_UOM | TO_UOM | CONVERSION_FACTOR | UOM_CATEGORY |
|---|---|---|---|
| ml | ml | 1.0 | VOLUME |
| cl | ml | 10.0 | VOLUME |
| L | ml | 1000.0 | VOLUME |
| fl_oz_UK | ml | 28.4131 | VOLUME |
| hf_pt_UK | ml | 284.131 | VOLUME |
| pt_UK | ml | 568.261 | VOLUME |
| gal | ml | 4546.09 | VOLUME |
| g | g | 1.0 | WEIGHT |
| kg | g | 1000.0 | WEIGHT |
| oz | g | 28.3495 | WEIGHT |
| each | each | 1.0 | COUNT |
| full | each | 1.0 | COUNT |
| portion | portion | 1.0 | SPECIAL |
| percentage | percentage | 1.0 | SPECIAL |

**Usage in staging:** Three-part naming from client DB context: `[core].[reference].[UOM_CONVERSION]`

## 6. Data Quality Mitigations

| Issue | Source | Severity | Mitigation |
|---|---|---|---|
| 104 duplicate product IDs | DL_PRODUCTS | HIGH | ROW_NUMBER PARTITION BY id ORDER BY LOADTS_UTC DESC |
| 25x recipe inflation | DL_RECIPES | HIGH | DISTINCT on relevant columns per staging purpose |
| 2.2x dish inflation | DL_DISHES | HIGH | ROW_NUMBER PARTITION BY id ORDER BY LOADTS_UTC DESC |
| 5x waste inflation | DL_WASTES | HIGH | ROW_NUMBER PARTITION BY wastesPerDay_id ORDER BY LOADTS_UTC |
| 4 duplicate barcodes (30 DN lines) | DL_DELIVERYNOTES | MEDIUM | ROW_NUMBER on product subquery PARTITION BY barcode, organizations |
| 68.8% NULL waste product_id | DL_WASTES | MEDIUM | Name-based resolution via DL_PRODUCTS (96.6% coverage) |
| NULL wasteMeasure on dish-based waste | DL_WASTES | MEDIUM | COALESCE fallback from product's default measure |
| 8.4% unmatched sales posIds | DL_SALESDETAIL | MEDIUM | Orphan LINEITEM rows — no PRODUCT link, still flow to CUSTORDER |
| Recipe unit mismatches | DL_DISHES x DL_RECIPES | MEDIUM | core.reference.UOM_CONVERSION with portion-aware logic |
| subOrgIds explosion | DL_ORGANIZATIONS | LOW | ROW_NUMBER PARTITION BY id |
| DL_PRODUCTS.supplierName mostly NULL | DL_PRODUCTS | LOW | COALESCE with supplier_name from DL_ORDERS |

## 7. Cross-Table Relationship Map

```
DL_ORGANIZATIONS (7 orgs = LOCATION)
    ^-- organizations FK from all tables
    |
DL_PRODUCTS (3,346 items = INVITEM)
    ^-- supplierId --> DL_SUPPLIERS (no table; resolved from DL_ORDERS supplier_*)
    ^-- mainProductId --> self (variant hierarchy)
    ^-- groupId (966 product groups)
    |
    |-- sections_elements_ingredient_product_id (ingredient FK)
    |
DL_RECIPES (119 recipes) ---dishes_id--> DL_DISHES
    ^-- sections_elements_recipe_recipe_id (recipe FK)
    |
DL_DISHES (2,158 menu items = PRODUCT)
    ^-- items_posId (POS ID FK, 91.6% match from sales)
    |
DL_SALESDETAIL (3,397 lines = LINEITEM) --> DL_SALES (2,380 = CUSTORDER)

DL_ORDERS (383 orders = STOCKORDER)
    ^-- po (PO reference, org-scoped)
    |
DL_DELIVERYNOTES (275 DNs = STOCKEVENT DELIVERY)
    ^-- products_barcode --> DL_PRODUCTS.barcode (99.7% match)

DL_WASTES (87 events = STOCKEVENT WASTE)
    ^-- products_product_id --> DL_PRODUCTS.id (31.2% direct)
    ^-- products_product_name --> DL_PRODUCTS.name (96.6% total via name resolution)
```

## 8. Phase 2 — Deferred Items

| Item | Reason | Prerequisites |
|---|---|---|
| DL_INVOICES -> HUB_INVOICE (new entity) | No existing DV hub; AP workflow; no product ID column | New DataVaultEntities records for INVOICE hub + links |
| Dish-based waste -> INVITEM via recipe explosion | 68.8% of waste records are dish-based with NULL product_id | Could resolve via dish -> recipe -> ingredient chain (complex) |
| POS <-> Inventory product reconciliation | posId -> dish_id mapping is integration-specific | Cross-integration matching layer needed |

## 9. Test Organisation Reference

- **Database:** `20251208_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14`
- **Organisation:** GrowyzeDev (OrgID 9)
- **Integration:** Growyze001 (IntegrationID 5, schema int_growyze001)
- **Growyze orgs:** 7 (including Padel Social Club, Earls Court, O2, Three Rocks, TR Enterprise, TR Sub 1, TR Sub 2)
- **Data volume:** ~3,346 products, 119 recipes, 2,158 dishes, 383 orders, 275 DNs, 2,380 sales, 87 waste events
