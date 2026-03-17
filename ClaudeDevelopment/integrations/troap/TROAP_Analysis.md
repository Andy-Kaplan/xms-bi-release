# TROAP Integration — Data Analysis

## 1. Overview

| Property | Value |
|---|---|
| **Integration Name** | TROaP001 (Three Rocks OaP Version 1) |
| **Integration Type** | POS |
| **Source System** | Internal Three Rocks ordering and payment platform ("OaP" — Order and Pay) |
| **Database** | `20251112_XMS_DBAB95ED-112E-42C6-B0E9-E0BFD20709D9` |
| **Schema** | `int_troap001` |
| **Analysis Date** | 2026-03-03 |
| **Order Date Range** | 2025-01-30 to 2026-03-02 (~13 months) |
| **Client** | Bella Italia (restaurant chain, ~75 physical locations across the UK) |

TROAP is a digital ordering platform (website/app) that feeds into Micros POS. Unlike NCRAloha and MarketMan which pull from third-party APIs, TROAP is an internal Three Rocks system. Orders originate digitally, are fired to Micros POS, and the platform captures the full lifecycle: basket creation, order placement, POS injection, payment, and post-order checks (charges, promotions, discounts).

The data model centres on `DL_Order` and `DL_CustomerOpenCheck` as the two primary transaction paths, joined via `OrderId`. The `CustomerOpenCheck` path captures in-venue activity (charges, tips, promotions, discounts) that occurs after the digital order is placed.

---

## 2. DL Table Inventory

41 DL tables ingested via the TROAP API. Classified by staging/mapping status.

### 2.1 Core Transaction Tables (Mapped)

| Table | Rows | Distinct Keys | Key Column | Notes |
|---|---|---|---|---|
| `DL_Order` | 48,453 | 47,732 distinct OrderIds | OrderId | Central transaction table; 721 duplicates (version updates via DateUpdated) |
| `DL_OrderItem` | 563,293 | 47,695 distinct orders / 1,753 distinct products | OrderItemId | ~11.8 items per order avg |
| `DL_OrderPayment` | 58,679 | 35,389 distinct orders | Id | 1.66 payments per order avg; 12,343 orders have no payment record |
| `DL_CustomerOpenCheck` | 149,578 | 149,577 distinct Ids | Id | In-venue check lifecycle; 48,223 have OrderId, 101,355 do not |
| `DL_CustomerOpenCheckCharge` | 94,552 | — | Id | Tips + service charges; keyed to CustomerOpenCheckId |
| `DL_CustomerOpenCheckDiscount` | 7,871 | 80 distinct DiscountIds | Id | Named discounts (Unidays, Friends, etc.) |
| `DL_CustomerOpenCheckPromotion` | 24,792 | — | Id | All "Promotion Applied" — line-level promotional savings |
| `DL_Store` | 243 | 243 StoreIds / 75 StoreName | StoreId | One row per SalesArea per physical store |
| `DL_Product` | 57,845 | 57,845 distinct ProductIds | ProductId | Per-store product variants; 1,462 toppings (cat 3) |
| `DL_ProductCategory` | 11 | 11 | ProductCategoryId | Static dimension: 0=None through 10=Food Menu RS |

### 2.2 Supporting Reference Tables (Not Mapped)

| Table | Rows | Purpose | Exclusion Reason |
|---|---|---|---|
| `DL_Customer` | 2,968,561 | Customer PII (name, email, phone) | Phase 2; CRM entity; PII sensitivity |
| `DL_Address` | 77 | Delivery/billing addresses | Sparse; Phase 2 with Customer |
| `DL_Basket` | 271,793 | Pre-order basket state | Superseded by DL_Order once placed |
| `DL_BasketItem` | 86,582 | Pre-order basket items | Superseded by DL_OrderItem |
| `DL_CustomerOpenCheckBasket` | 271,681 | Check-to-basket mapping | Bridge table; not needed for DV |
| `DL_CustomerOpenCheckCouponDiscount` | 7,997 | Coupon discount applications | Low cardinality; could merge with Discount |
| `DL_CouponDiscount` | 8,489 | Coupon definitions | Reference for coupon discounts |
| `DL_Price` | 207,040 | Product pricing by store/band | Static pricing reference |
| `DL_MenuProduct` | 207,175 | Menu-to-product mapping | Menu configuration, not transactional |
| `DL_Menu` | 135 | Menu definitions | Menu configuration |
| `DL_MenuCategory` | 669 | Menu category definitions | Menu configuration |
| `DL_MenuCategoryGroup` | 4,161 | Menu category groupings | Menu configuration |
| `DL_MenuPriceBand` | 669 | Price band definitions | Menu configuration |
| `DL_ZonalMenu` | 669 | Zonal menu definitions | POS-side menu config |
| `DL_ZonalProduct` | 57,844 | Zonal product definitions | POS-side product config |
| `DL_ProductBase` | 12 | Product base types (pizza bases) | Low cardinality config |
| `DL_Allergen` | 14 | Allergen definitions | Reference data; Phase 2 |
| `DL_AllowedStores` | 139 | Store allow-list | Configuration |
| `DL_AvailabilityRule` | 11 | Availability rules | Configuration |
| `DL_AvailabilityRuleValidDays` | 7 | Day-of-week rules | Configuration |
| `DL_Device` | 17 | Device registrations | Infrastructure |
| `DL_BrainTreePaymentIntent` | 56,875 | Payment gateway intents | Payment infrastructure |
| `DL_BrainTreePaymentLog` | 38,805 | Payment gateway logs | Payment infrastructure |
| `DL_StoreOpeningHours` | 1,631 | Store opening hours | Operational config |
| `DL_StoreOpeningHoursGroup` | 1 | Opening hours grouping | Operational config |
| `DL_StoreOrderType` | 132 | Supported order types per store | Configuration |
| `DL_StoreProductOutOfStock` | 17,416 | Out-of-stock flags | Operational state |
| `DL_OrderRefundQueue` | 5 | Refund processing queue | Minimal data |
| `DL_OrderSplitBill` | 5,704 | Split bill headers | Phase 2 candidate |
| `DL_OrderSplitBillItem` | 16,407 | Split bill line items | Phase 2 candidate |
| `DL_OrderSplitBillPayment` | 13,914 | Split bill payments | Phase 2 candidate |

---

## 3. Dimension Analysis

### 3.1 Stores / LOCATION

**Source:** `DL_Store` (243 rows)

TROAP stores have a unique structure: each physical restaurant has multiple `StoreId` values, one per **SalesAreaName**. This means a single Bella Italia location may have 2-4 store records.

| SalesAreaName | Store Records | Distinct Stores |
|---|---|---|
| Restaurant | 124 | 124 |
| Outside | 96 | 96 |
| Upstairs | 14 | 14 |
| Bar | 4 | 4 |
| Downstairs | 3 | 3 |
| Room Service | 2 | 2 |
| **Total** | **243** | **243** |

**Key observations:**
- **75 unique physical locations** (distinct StoreName values)
- **243 StoreIds** — each SalesAreaName generates a separate StoreId
- Most stores have 2 areas (Restaurant + Outside); 8 have 3 areas; a few have up to 9 StoreIds (Taplow has 9 due to active/inactive pairs per area)
- Staging uses `StoreId` as the LOCATION SRC_KEY, so each sales area is a separate location in the Data Vault
- `SalesAreaName` maps to the OCCASION dimension (it represents the service context)
- 181 distinct StoreIds appear on orders (62 StoreIds have no order activity)
- Active/inactive flag present (`IsActive`): some stores have both an active and inactive record for the same area (store reconfiguration)

**Design decision:** Treat each StoreId as a distinct LOCATION. The SalesAreaName is the OCCASION. This mirrors how Micros POS treats revenue centres — each area is operationally distinct for reporting purposes.

### 3.2 Products & Categories / PRODUCT

**Source:** `DL_Product` (57,845 rows) + `DL_ProductCategory` (11 rows)

Products are **per-store variants** — the same menu item appears once per store it is available in. The DL_Product table has 57,845 rows but these represent far fewer unique menu items replicated across stores.

| Category | ID | Products in DL_Product | Items on Orders | Distinct Products on Orders |
|---|---|---|---|---|
| None | 0 | 1 | 180,277 | 4 |
| Sides | 1 | 0 | 0 | 0 |
| Pizza | 2 | 0 | 0 | 0 |
| **Topping** | **3** | **1,462** | **85,280** | **776** |
| Breakfast | 4 | 537 | 62,914 | 199 |
| A La Carte | 5 | 15,574 | 117,162 | 158 |
| Desserts | 6 | 1,997 | 15,257 | 110 |
| Set Menu | 7 | 6,027 | 26,145 | 180 |
| Kids | 8 | 6,131 | 32,271 | 431 |
| Drinks | 9 | 26,075 | 43,705 | 366 |
| Food Menu RS | 10 | 41 | 282 | 80 |

**Key observations:**
- **Category 3 (Topping)** = modifiers: 1,462 products, 85,280 order items. These map to the MOD entity.
- **Category 0 (None)**: Only 1 product in DL_Product but 4 distinct ProductIds on orders (180,277 items). These are zero-price system items ("Finished your Mains?", "Dessert Away") — course markers/prompts, not real products. Excluded from staging.
- Categories 1 (Sides) and 2 (Pizza) have products defined in DL_ProductCategory but zero products in DL_Product or on orders — unused categories.
- Category 10 (Food Menu RS) is Room Service specific — very low volume (282 items).
- All 57,845 products have a ProductCategoryId (zero NULLs).

**Design decision:** Products with `ProductCategoryId = 3` are staged as MOD. All others (excluding category 0) are staged as PRODUCT. The `ProductCategoryId` itself maps to the entity hierarchy as a categorisation attribute.

### 3.3 Modifiers / MOD

**Source:** `DL_OrderItem` WHERE `ProductCategoryId = '3'`

Modifiers are toppings/customisations added to menu items. In TROAP, these are identified by `ProductCategoryId = 3` (Topping category).

- **85,280** modifier line items on orders
- **776** distinct modifier ProductIds appear on orders (from 1,462 in the product catalog)
- Modifiers always have an `OrderItemParentId` linking them to their parent product line

**Modifier vs parent split on DL_OrderItem:**
| Type | Count | % |
|---|---|---|
| No OrderItemParentId (products) | 491,145 | 87.2% |
| Has OrderItemParentId (modifiers/children) | 72,148 | 12.8% |
| **Total** | **563,293** | **100%** |

Note: Not all items with an `OrderItemParentId` are category 3 toppings — some are combo meal components (linked via `MicrosComboMealId`/`MicrosComboGroupId`). The category filter is the reliable modifier identifier.

### 3.4 Channels / CHANNEL

**Source:** `DL_Order.ClientApplication`

| ClientApplication | Meaning |
|---|---|
| `OLO2_Website` | Online ordering website (100% of orders) |

All 48,453 orders come from a single channel: `OLO2_Website`. This is expected — TROAP is a web ordering platform. No mobile app or kiosk channels are present in this dataset.

**Design decision:** The `ClientApplication` value is staged directly as the CHANNEL SRC_KEY. Currently single-valued but the staging supports future channel expansion.

### 3.5 Occasions / OCCASION

**Source:** `DL_Store.SalesAreaName`

TROAP does not have an explicit occasion table. The `SalesAreaName` on the store record serves as the occasion/service context, representing where in the restaurant the order is fulfilled.

| SalesAreaName | Meaning |
|---|---|
| Restaurant | Main dining area |
| Outside | Outdoor/terrace seating |
| Upstairs | Upper floor dining |
| Bar | Bar area |
| Downstairs | Lower floor dining |
| Room Service | Hotel room service (Center Parcs locations) |

**Design decision:** `SalesAreaName` is derived via join from `DL_Store` on the order's `StoreId`. This becomes the OCCASION SRC_KEY in staging. Each SalesAreaName represents a distinct service context.

### 3.6 Revenue Centres / REVCENTER

**Source:** `DL_Order.MicrosRevenueCentre`

All 48,453 orders have `MicrosRevenueCentre = '-1'` — a placeholder/default value. The TROAP platform does not set the Micros revenue centre at order creation time (it is assigned after POS injection).

**Design decision:** Not staged. The single placeholder value provides no analytical value. If future data includes meaningful revenue centre IDs, staging can be added.

### 3.7 Deals / Promotions / DEAL

**Source:** `DL_CustomerOpenCheckPromotion` (24,792 rows)

All promotion records have `Name = 'Promotion Applied'` — a generic label. The meaningful data is in the financial columns:

| Field | Description | Example |
|---|---|---|
| `FullPrice` | Original price before promotion | 13.50 |
| `PromotedPrice` | Price after promotion | 0.00 or 13.50 |
| `PromotionalSaving` | Discount amount | 3.99 or 0.00 |
| `DiscountApplyingToOrderLineFamily` | Line family identifier | 0.0 |

Promotions link to `DL_CustomerOpenCheck` via `CustomerOpenCheckId`, which in turn links to `DL_Order` via `OrderId`.

**Design decision:** Promotions are staged as DEAL entities. The `Id` is the SRC_KEY. The `Name` field ('Promotion Applied') is the deal name, with financial details (`FullPrice`, `PromotedPrice`, `PromotionalSaving`) as attributes.

### 3.8 Discounts / DISCOUNT

**Source:** `DL_CustomerOpenCheckDiscount` (7,871 rows, 80 distinct DiscountIds)

| Name | Count | Notes |
|---|---|---|
| Discount applied | 6,364 | Generic POS-applied discount |
| N BTG 30% Unidays Fd | 1,318 | Unidays student discount |
| N CDG 50% SO | 97 | 50% staff offer |
| N BTG 25% Friends | 92 | Friends & family discount |

Discount records contain a `DiscountId` (80 distinct values) and an `Amount`. They link to `DL_CustomerOpenCheck` via `CustomerOpenCheckId`.

**Design decision:** Discounts are staged as DISCOUNT entities. `DiscountId` is the SRC_KEY, `Name` is the discount name, and `Amount` is the monetary value.

### 3.9 Tenders / Payment Methods / TENDER

**Source:** `DL_OrderPayment` (58,679 rows)

| PaymentMethodId | Description | Count |
|---|---|---|
| 1 | Payment method 1 (likely card) | ~20,706* |
| 4 | Payment method 4 (likely digital wallet) | — |

*Exact split by PaymentMethodId not queried; total is 58,679 payments across 35,389 distinct orders.

**Payment status breakdown:**
| PaymentStatusId | Count | Likely Meaning |
|---|---|---|
| 2 | 39,495 | Completed/Settled |
| 1 | 14,933 | Pending/Authorised |
| 3 | 2,655 | Declined/Failed |
| 9 | 1,591 | Refunded |
| 13 | 5 | Unknown/Other |

**Design decision:** `PaymentMethodId` is staged as the TENDER SRC_KEY. The ID is opaque (numeric) but represents the payment instrument type. Multiple payments per order are supported (58,679 payments for 35,389 orders = 1.66 per order).

### 3.10 Service Charges / SERVICECHARGE

**Source:** `DL_CustomerOpenCheckCharge` (94,552 rows)

| Name | ChargeTypeId | Count | Notes |
|---|---|---|---|
| Optional Service Charge | 1 | 47,321 | Percentage-based service charge |
| Tip | 2 | 40,160 | Customer tip |
| *(null)* | 2 | 6,154 | Tip with no name |
| *(null)* | 1 | 917 | Service charge with no name |

All 94,552 records have `IsCustomTip = '0'` (false). The `ChargeTypeId` is the discriminator:
- **ChargeTypeId 1** = Service charges (48,238 total)
- **ChargeTypeId 2** = Tips (46,314 total)

Additional columns: `ChargePercentage`, `ChargeAmount`, `MonetaryChargeTypeId`, `IsPaid`, `OrderPaymentId`, `CustomerId`.

**Design decision:** Charges are staged as SERVICECHARGE entities. The composite key is `CustomerOpenCheckId + Id`. `ChargeTypeId` and `Name` are attributes. Tips and service charges are unified under the same entity since the DV SERVICECHARGE hub is designed to hold both.

---

## 4. Transaction Analysis

### 4.1 Orders / CUSTORDER

**Source:** `DL_Order` (48,453 rows, 47,732 distinct OrderIds)

| Metric | Value |
|---|---|
| Total rows | 48,453 |
| Distinct OrderIds | 47,732 |
| Duplicate OrderIds | 721 (version updates) |
| Date range | 2025-01-30 to 2026-03-02 |
| Distinct StoreIds | 181 |
| Null OrderId | 0 |
| Null CustomerId | 0 |
| Null StoreId | 0 |

**Order status breakdown:**
| OrderStatusId | Count | Likely Meaning |
|---|---|---|
| 2 | 27,747 | Completed |
| 1 | 20,706 | Placed/In Progress |

**Payment status (on order):**
| PaymentStatusId | Count | Likely Meaning |
|---|---|---|
| 2 | 27,747 | Paid |
| 1 | 20,706 | Pending |

**Key fields for staging:**
- `OrderId` — CUSTORDER SRC_KEY
- `StoreId` — joins to DL_Store for LOCATION
- `DateCreated` — ORDER_DATE
- `TotalPriceNet`, `TotalPriceVat`, `TotalPriceTotal` — financial amounts
- `ClientApplication` — CHANNEL
- `ShipmentTypeId` — always '9' (single delivery type)
- `MicrosRevenueCentre` — always '-1' (not used)
- `MicrosOrderTypeId` — always '0' (single type)
- `TableNumber` — table assignment in restaurant

**Key columns NOT staged:** `CustomerId`, `BillingAddressId`, `DeliveryAddressId` (Phase 2 — CRM), `Token`, `ShopperIPAddress`, `UserAgent` (PII/infrastructure), `VoucherActualCode` (coupon detail).

### 4.2 Order Items / LINEITEM

**Source:** `DL_OrderItem` (563,293 rows)

| Metric | Value |
|---|---|
| Total rows | 563,293 |
| Distinct OrderIds | 47,695 |
| Distinct ProductIds | 1,753 |
| Null OrderId | 0 |
| Null ProductId | 0 |
| Items with OrderItemParentId | 72,148 (12.8%) |
| Items without OrderItemParentId | 491,145 (87.2%) |
| Items matched to DL_Order | 563,290 |
| Orphaned items (no matching order) | 3 |

**Category split on order items:**
| Category | Items | % | Staging |
|---|---|---|---|
| None (0) — system markers | 180,277 | 32.0% | Excluded |
| Topping (3) — modifiers | 85,280 | 15.1% | MOD entity |
| Products (4-10) | 297,736 | 52.9% | LINEITEM entity |
| **Total** | **563,293** | **100%** | — |

**Key fields for staging:**
- `OrderItemId` — LINEITEM SRC_KEY (for products) or MOD SRC_KEY (for toppings)
- `OrderId` — links to CUSTORDER
- `ProductId` — links to PRODUCT or MOD
- `Quantity`, `PriceNet`, `PriceVat`, `PriceTotal` — financial columns
- `OrderItemParentId` — parent-child relationship (combo meals, modifier attachment)
- `ProductCategoryId` — discriminator for PRODUCT vs MOD routing

**Exclusion: Category 0 items** — 180,277 items (32% of all items) are system-generated course markers with zero or near-zero prices ("Finished your Mains?", "Dessert Away"). Only 4 distinct ProductIds. Excluded from staging to avoid polluting LINEITEM with non-transactional records.

### 4.3 Payments / TENDER

**Source:** `DL_OrderPayment` (58,679 rows)

| Metric | Value |
|---|---|
| Total payment records | 58,679 |
| Distinct payment Ids | 58,679 |
| Distinct OrderIds with payments | 35,389 |
| Total distinct orders | 47,732 |
| Orders without payment records | 12,343 (25.9%) |
| Avg payments per order (with payment) | 1.66 |

The 25.9% gap between orders and payments is expected — orders with `OrderStatusId = 1` (Placed/In Progress) may not yet have payment records, or payment is handled through the Micros POS side rather than the TROAP digital payment flow.

### 4.4 Charges / Service Charges

**Source:** `DL_CustomerOpenCheckCharge` (94,552 rows)

| ChargeTypeId | Name | Count | % |
|---|---|---|---|
| 1 | Optional Service Charge | 47,321 | 50.1% |
| 2 | Tip | 40,160 | 42.5% |
| 2 | *(null name)* | 6,154 | 6.5% |
| 1 | *(null name)* | 917 | 0.9% |

Charges link to `DL_CustomerOpenCheck` via `CustomerOpenCheckId`. The check links to `DL_Order` via `OrderId` (when populated).

### 4.5 Promotions / Deals

**Source:** `DL_CustomerOpenCheckPromotion` (24,792 rows)

All records have `Name = 'Promotion Applied'`. The data is item-level: each promotion record represents a promotional adjustment to a specific line item, with `FullPrice`, `PromotedPrice`, and `PromotionalSaving` capturing the financial impact.

Promotions link to `DL_CustomerOpenCheck` via `CustomerOpenCheckId`.

### 4.6 Discounts

**Source:** `DL_CustomerOpenCheckDiscount` (7,871 rows)

80 distinct `DiscountId` values. Discounts are check-level (not item-level) and represent named discount programmes:
- Generic "Discount applied" (81%)
- Named programmes: Unidays (student), staff offers, friends & family (19%)

Discounts link to `DL_CustomerOpenCheck` via `CustomerOpenCheckId`.

---

## 5. Join Integrity

### 5.1 CustomerOpenCheck to Order

| Metric | Value |
|---|---|
| Total CustomerOpenCheck records | 149,578 |
| Records with OrderId populated | 48,223 (32.2%) |
| Records without OrderId | 101,355 (67.8%) |
| Populated OrderIds matching DL_Order | 47,580 (98.7% of those with OrderId) |
| Unmatched OrderIds | 643 (1.3%) |

**67.8% of CustomerOpenCheck records have no OrderId.** These represent in-venue checks that were opened but not linked to a TROAP digital order — e.g., walk-in customers, POS-originated checks, or abandoned checks. Only checks with a valid OrderId can be joined to the order pipeline.

The 643 unmatched OrderIds (1.3%) likely represent orders that were cancelled or purged from DL_Order but whose check records persist.

### 5.2 OrderItem to Order

| Metric | Value |
|---|---|
| OrderItems with matching order | 563,290 |
| Orphaned OrderItems | 3 |
| Coverage | 99.9995% |

Near-perfect join integrity. The 3 orphaned items are negligible (likely race condition during data ingestion).

### 5.3 OrderPayment to Order

| Metric | Value |
|---|---|
| Orders with at least one payment | 35,389 |
| Orders without any payment | 12,343 |
| Payment coverage | 74.1% |

Not all orders have payment records in TROAP — some are paid via the Micros POS directly.

### 5.4 Store Deduplication

| Metric | Value |
|---|---|
| Total StoreId records | 243 |
| Unique physical stores (StoreName) | 75 |
| Avg StoreIds per physical store | 3.24 |
| Stores with 2 areas | 49 |
| Stores with 3 areas | 8 |
| Max StoreIds per StoreName | 9 (Bella Italia Taplow) |

Many physical stores have both active and inactive StoreId records for the same SalesAreaName (e.g., Bella Italia Blackpool has 4 StoreIds: Restaurant active + inactive, Outside active + inactive). This is due to store reconfiguration — old records deactivated, new ones created.

**Staging handles this correctly** by using `StoreId` as the LOCATION SRC_KEY. Each StoreId is a distinct location record regardless of active status. The `IsActive` flag is available as a satellite attribute for filtering.

---

## 6. Data Quality Notes

### 6.1 NULL Handling

| Column | Table | NULL Count | Impact |
|---|---|---|---|
| OrderId | DL_Order | 0 | Clean |
| CustomerId | DL_Order | 0 | Clean |
| StoreId | DL_Order | 0 | Clean |
| OrderId | DL_OrderItem | 0 | Clean |
| ProductId | DL_OrderItem | 0 | Clean |
| OrderId | DL_CustomerOpenCheck | 101,355 blank | Expected — not all checks have orders |
| Name | DL_CustomerOpenCheckCharge | 7,071 null | 7.5% of charges have no name; ChargeTypeId still present |
| ProductCategoryId | DL_Product | 0 | Clean — all products categorised |

### 6.2 Duplicate Detection

- **DL_Order**: 48,453 rows, 47,732 distinct OrderIds = 721 duplicates (1.5%). These are version updates (same OrderId, different DateUpdated). Staging should use ROW_NUMBER() OVER (PARTITION BY OrderId ORDER BY DateUpdated DESC) to select the latest version.
- **DL_Product**: 57,845 rows = 57,845 distinct ProductIds. No duplicates.
- **DL_CustomerOpenCheck**: 149,578 rows, 149,577 distinct Ids. 1 duplicate — negligible.

### 6.3 Business Key Uniqueness

All primary business keys (OrderId, OrderItemId, ProductId, StoreId, payment Id, check Id) are effectively unique or have controlled duplicates (version updates). No data quality issues with key uniqueness.

### 6.4 Known Data Issues

1. **Category 0 items dominate order items** — 180,277 items (32%) are zero-price system markers. Must be excluded from LINEITEM staging.
2. **Single ClientApplication** — all orders are `OLO2_Website`. No channel diversity currently.
3. **MicrosRevenueCentre always '-1'** — no POS revenue centre data flows back to TROAP.
4. **MicrosOrderTypeId always '0'** — single order type.
5. **ShipmentTypeId always '9'** — single shipment type. These single-valued fields provide no analytical value in current data but staging supports future expansion.
6. **Promotion Name always 'Promotion Applied'** — no named promotions; deal names are generic.
7. **67.8% of CustomerOpenChecks have no OrderId** — charges/promotions/discounts on these checks cannot be linked to digital orders.

---

## 7. Design Decisions

### 7.1 Table Exclusions

| Excluded Table | Reason |
|---|---|
| DL_Customer (2.97M rows) | Phase 2 — CRM entity; PII concerns; requires CUSTOMER hub |
| DL_Address (77 rows) | Phase 2 — pairs with Customer |
| DL_Basket / DL_BasketItem | Pre-order state; superseded by Order/OrderItem once order is placed |
| DL_CustomerOpenCheckBasket | Bridge table between check and basket; not needed |
| DL_BrainTreePayment* | Payment gateway infrastructure; not analytical |
| DL_CouponDiscount / COC_CouponDiscount | Phase 2 — could merge with discount pipeline |
| DL_Menu / MenuCategory / MenuCategoryGroup / MenuPriceBand / MenuProduct | Menu configuration data; not transactional |
| DL_ZonalMenu / ZonalProduct | POS-side menu configuration |
| DL_ProductBase (12 rows) | Static pizza base types; low value |
| DL_Price (207K rows) | Pricing reference; not transactional. Price captured on order items. |
| DL_Allergen / AllowedStores / AvailabilityRule* | Reference/config data |
| DL_Device | Infrastructure |
| DL_StoreOpeningHours* / StoreOrderType / StoreProductOutOfStock | Operational state data |
| DL_OrderRefundQueue (5 rows) | Minimal data |
| DL_OrderSplitBill* | Phase 2 — split bill analysis; 5,704 bills |

### 7.2 Modifier Identification Strategy

Modifiers are identified by `ProductCategoryId = '3'` (Topping) on the `DL_OrderItem` table. This is more reliable than using `OrderItemParentId` because:
- Parent-child relationships also exist for combo meal components (not modifiers)
- Category 3 is explicitly defined as "Topping" in the product category table
- All modifier products in DL_Product also have `ProductCategoryId = '3'`

### 7.3 SRC_KEY Composite Patterns

| Entity | SRC_KEY Pattern | Example |
|---|---|---|
| LOCATION | `StoreId` | `'131'` |
| PRODUCT | `ProductId` | `'5432'` |
| MOD | `ProductId` (category 3 products) | `'776'` |
| CUSTORDER | `OrderId` | `'98765'` |
| LINEITEM | `OrderItemId` | `'123456'` |
| CHANNEL | `ClientApplication` | `'OLO2_Website'` |
| OCCASION | `SalesAreaName` (from Store) | `'Restaurant'` |
| TENDER | `PaymentMethodId` | `'1'` |
| DEAL | `Id` (from Promotion) | `'17063'` |
| DISCOUNT | `DiscountId` | `'1834'` |
| SERVICECHARGE | `Id` (from Charge) | `'50001'` |

### 7.4 Phase 2 Candidates

| Feature | Tables | Entity Impact |
|---|---|---|
| Customer analytics | DL_Customer, DL_Address | New CUSTOMER hub + links |
| Split bill analysis | DL_OrderSplitBill, Item, Payment | New entity or LINEITEM extension |
| Coupon tracking | DL_CouponDiscount, COC_CouponDiscount | DISCOUNT extension |
| Allergen reporting | DL_Allergen, product-allergen mapping | PRODUCT satellite extension |
| Menu structure | DL_Menu, MenuCategory, MenuProduct | PRODUCT hierarchy extension |
| Pricing analysis | DL_Price, DL_MenuPriceBand | PRODUCT satellite extension |

---

## 8. Staging & Mapping Summary

### 8.1 Staging Steps

**20 staging steps** across 2 tiers:

**Tier 1 — 12 steps** (direct DL table transformations):

| Step | Source | Target Entity | Notes |
|---|---|---|---|
| TROAP_STORE | DL_Store | LOCATION | StoreId as SRC_KEY; StoreName, SalesAreaName, IsActive |
| TROAP_PRODUCT | DL_Product | PRODUCT | WHERE ProductCategoryId != '3'; product attributes |
| TROAP_MOD | DL_Product | MOD | WHERE ProductCategoryId = '3'; topping attributes |
| TROAP_PRODUCTCATEGORY | DL_ProductCategory | CATEGORY | ProductCategoryId/Name hierarchy |
| TROAP_CHANNEL | DL_Order | CHANNEL | DISTINCT ClientApplication values |
| TROAP_OCCASION | DL_Store | OCCASION | DISTINCT SalesAreaName values |
| TROAP_ORDER | DL_Order | CUSTORDER | Latest version per OrderId; financial totals |
| TROAP_ORDERITEM | DL_OrderItem | LINEITEM | WHERE ProductCategoryId != '0' AND != '3'; product lines |
| TROAP_ORDERITEM_MOD | DL_OrderItem | LINEITEM (mod) | WHERE ProductCategoryId = '3'; modifier lines |
| TROAP_ORDERPAYMENT | DL_OrderPayment | TENDER payment | PaymentMethodId; financial amounts |
| TROAP_DISCOUNT | DL_CustomerOpenCheckDiscount | DISCOUNT | Via COC join; DiscountId, Name, Amount |
| TROAP_SERVICECHARGE | DL_CustomerOpenCheckCharge | SERVICECHARGE | Via COC join; ChargeTypeId, Name, Amount |

**Tier 2 — 8 steps** (join-dependent transformations):

| Step | Sources | Target Entity | Notes |
|---|---|---|---|
| TROAP_ORDER_LOCATION | DL_Order + DL_Store | CUSTORDER-LOCATION link | Order → Store join |
| TROAP_ORDER_CHANNEL | DL_Order | CUSTORDER-CHANNEL link | ClientApplication from order |
| TROAP_ORDER_OCCASION | DL_Order + DL_Store | CUSTORDER-OCCASION link | Store → SalesAreaName |
| TROAP_LINEITEM_PRODUCT | DL_OrderItem + DL_Product | LINEITEM-PRODUCT link | OrderItem → Product join |
| TROAP_LINEITEM_MOD | DL_OrderItem | LINEITEM-MOD link | Modifier → parent product |
| TROAP_ORDER_TENDER | DL_OrderPayment + DL_Order | CUSTORDER-TENDER link | Payment method per order |
| TROAP_DEAL | DL_CustomerOpenCheckPromotion + COC | DEAL + CUSTORDER-DEAL link | Promotion via COC→Order |
| TROAP_ORDER_DISCOUNT | DL_CustomerOpenCheckDiscount + COC | CUSTORDER-DISCOUNT link | Discount via COC→Order |

### 8.2 Entity Mappings

**25 entity mappings** (12 hubs + 13 links):

**Hubs (12):**
| Entity | Type | Source Step |
|---|---|---|
| LOCATION | Hub | TROAP_STORE |
| PRODUCT | Hub | TROAP_PRODUCT |
| MOD | Hub | TROAP_MOD |
| CATEGORY | Hub | TROAP_PRODUCTCATEGORY |
| CHANNEL | Hub | TROAP_CHANNEL |
| OCCASION | Hub | TROAP_OCCASION |
| CUSTORDER | Hub | TROAP_ORDER |
| LINEITEM | Hub | TROAP_ORDERITEM |
| TENDER | Hub | TROAP_ORDERPAYMENT |
| DEAL | Hub | TROAP_DEAL |
| DISCOUNT | Hub | TROAP_DISCOUNT |
| SERVICECHARGE | Hub | TROAP_SERVICECHARGE |

**Links (13):**
| Link | Hubs Connected | Source Step |
|---|---|---|
| LNK_CUSTORDER_LOCATION | CUSTORDER + LOCATION | TROAP_ORDER_LOCATION |
| LNK_CUSTORDER_CHANNEL | CUSTORDER + CHANNEL | TROAP_ORDER_CHANNEL |
| LNK_CUSTORDER_OCCASION | CUSTORDER + OCCASION | TROAP_ORDER_OCCASION |
| LNK_LINEITEM_CUSTORDER | LINEITEM + CUSTORDER | TROAP_ORDERITEM |
| LNK_LINEITEM_PRODUCT | LINEITEM + PRODUCT | TROAP_LINEITEM_PRODUCT |
| LNK_LINEITEM_MOD | LINEITEM + MOD | TROAP_LINEITEM_MOD |
| LNK_LINEITEM_LINEITEM | LINEITEM + LINEITEM | TROAP_ORDERITEM (parent-child) |
| LNK_PRODUCT_CATEGORY | PRODUCT + CATEGORY | TROAP_PRODUCT |
| LNK_MOD_CATEGORY | MOD + CATEGORY | TROAP_MOD |
| LNK_CUSTORDER_TENDER | CUSTORDER + TENDER | TROAP_ORDER_TENDER |
| LNK_CUSTORDER_DEAL | CUSTORDER + DEAL | TROAP_DEAL |
| LNK_CUSTORDER_DISCOUNT | CUSTORDER + DISCOUNT | TROAP_ORDER_DISCOUNT |
| LNK_CUSTORDER_SERVICECHARGE | CUSTORDER + SERVICECHARGE | TROAP_SERVICECHARGE |

### 8.3 Coverage Matrix

| DV Entity | TROAP Mapped? | Notes |
|---|---|---|
| LOCATION | Yes | 243 StoreIds (75 physical stores) |
| PRODUCT | Yes | ~56,383 products (excl. toppings) |
| MOD | Yes | 1,462 topping products |
| CATEGORY | Yes | 11 categories (0-10) |
| CHANNEL | Yes | 1 value (OLO2_Website) |
| OCCASION | Yes | 6 SalesAreaNames |
| CUSTORDER | Yes | 47,732 orders |
| LINEITEM | Yes | ~383,016 product items (excl. cat 0 + toppings) |
| TENDER | Yes | 2 PaymentMethodIds |
| DEAL | Yes | 24,792 promotion records |
| DISCOUNT | Yes | 80 distinct discounts |
| SERVICECHARGE | Yes | 94,552 charge records |
| POSTX | No | TROAP has no separate POS transaction concept |
| EMPLOYEE | No | Not available in TROAP data |
| TIMECARD | No | Not available |
| JOB | No | Not available |
| COMP | No | Not applicable |
| REVCENTER | No | Always '-1'; no data |
| CUSTOMER | No | Phase 2 (2.97M customers in DL_Customer) |
| All Inventory entities | No | TROAP is POS only, no inventory data |
