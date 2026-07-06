# Bizon POS Integration Design — `Bizon001`

**Date:** 2026-04-09
**Status:** DRAFT
**Integration:** `Bizon001` / `int_bizon001` / IntegrationType `POS`
**API:** Mews POS API v1 (`https://api.mews.com/pos/v1/`)
**API Format:** JSON:API (not plain JSON — see §8.1)

---

## 1. Overview

Bizon is a POS system built on the Mews hospitality platform. The Mews POS API provides order management, invoicing, product catalogs, table bookings, payment processing, and revenue center segmentation. This design adds Bizon as a new POS integration in XMS BI alongside NCRAloha, TROAP, and Square.

### Key Design Decisions

1. **Invoice is the CUSTORDER source** — Mews separates Orders (in-progress checks) from Invoices (finalized bills). Invoices carry accurate financial totals and payment status. Orders carry operational metadata (covers, table, booking). Both are ingested; CUSTORDER maps from Invoice joined to Order. This avoids double-counting and handles split-bill scenarios correctly. **Split-bill note:** each split invoice carries the full `covers` count from the parent Order — we do not divide covers across split invoices, as partial cover counts would produce confusing results in queries that don't aggregate all splits together. **`closed` status note:** the meaning of Mews invoice status `closed` (vs `paid`) needs validation against sample data — it may represent deferred hotel billing rather than a completed payment. Start with `status = 'paid'` filter only; revisit when sample data is available.
2. **BOOKING hub promoted to Live** — Mews table bookings are a first-class concept. New Live DV entities: `BOOKING` (hub v2) with satellite attributes, and `BOOKING_CUSTORDER` (binary link). The existing Build-state ternary `ASSET_BOOKING_CUSTORDER` is left unchanged.
3. **No presentation layer changes** — existing tables and vis queries work unchanged.
4. **Revenue Centers → REVCENTER only** — Mews Revenue Centers map to the existing REVCENTER hub and CUSTORDER_REVCENTER link. OCCASION is **not mapped** — there is no obvious occasion (dine-in/takeaway/delivery) concept in the Mews POS API. Revenue Centers are financial segmentation, not service occasion.
5. **Areas → CHANNEL** — Mews dining areas (Bar, Terrace, Main Floor) map to CHANNEL, giving spatial context to orders.
6. **String decimals** — Mews amounts are strings ("10.50"), not integer cents. Staging uses `CAST(field AS DECIMAL(18,2))` with no division.
7. **JSON:API format — fetcher team action required** — Mews uses JSON:API (`application/vnd.api+json`) with `data`/`included` sideloading, `relationships` references, and `attributes` wrappers. This is structurally different from the plain REST JSON used by NCRAloha and Square. **The fetcher team will need to build a new JSON:API unravel method** into the fetcher process. This is a prerequisite for the integration — DL tables onward follow standard platform patterns, but the data cannot land without JSON:API support in the fetcher.
8. **No workforce steps** — Mews POS API does not expose a native timeclock/shift endpoint. EMPLOYEE, JOB, and TIMECARD entities are not mapped. If a future Mews workforce API becomes available, these can be added as a separate enhancement.
9. **Deal data via LINEITEM_LINEITEM** — Mews product bundles are handled through the self-referencing LINEITEM_LINEITEM link (bundle parent → component children), same pattern as modifier→product. DEAL entity activation is not required.

### Scope

| Aspect | Detail |
|---|---|
| DL tables | 26 |
| Staging steps | 36 (20 Tier 1 + 15 Tier 2 + 1 Tier 3) |
| Entity mappings | 40 (25 hub + 15 link) |
| New DV entities | 2 (BOOKING v2 Live hub, BOOKING_CUSTORDER Live link) |
| Presentation changes | None |
| Known gaps | F_PRODUCT_MARGIN_DAY cost data, DimCustomer pipeline, `closed` invoice status semantics |
| Estimated script volume | ~4,500–5,000 lines across 5 files |

### Data Flow

```
Mews POS API → fetcher → int_bizon001.DL_* tables
  → stage.BIZ_* tables (Tier 1: dimensions + base facts)
  → stage.BIZ_* tables (Tier 2: link staging)
  → stage.BIZ_* tables (Tier 3: self-referencing links)
  → load.{ENTITY} → datavault.HUB/SAT/LNK/SAT_LNK.*
  → presentation.F_*/D_* (existing tables, no changes)
  → VisualisationQueries (existing queries, no changes)
```

---

## 2. DL Table Inventory

All columns `NVARCHAR(MAX) NULL` plus the two mandatory system columns (`LOADTS_UTC datetime2`, `INT_FETCH_DATE datetime2`). Column names use camelCase matching the Mews API field names.

### 2.1 Orders Endpoint (`GET /v1/orders`) — 5 Tables

**`DL_ORDERS`** — Order headers

| Column | Mews API Source |
|---|---|
| `id` | Order.id |
| `outletId` | Order.relationships.outlet.data.id |
| `revenueCenterId` | Order.relationships.revenueCenter.data.id |
| `customerId` | Order.relationships.customer.data.id |
| `bookingId` | Order.relationships.booking.data.id |
| `invoiceId` | Order.relationships.invoice.data.id |
| `promoCodeId` | Order.relationships.promoCode.data.id |
| `state` | Order.attributes.state (draft/sent/paid/discarded/cart/pending_payment/open/open_web) |
| `status` | Order.attributes.status (received/confirmed/rejected/preparing/ready_for_delivery/dispatched/in_transit/delivered) |
| `tableStatus` | Order.attributes.tableStatus (no_table/seated/cleaning/free) |
| `notes` | Order.attributes.notes |
| `covers` | Order.attributes.covers |
| `depositAmount` | Order.attributes.depositAmount |
| `surcharge` | Order.attributes.surcharge |
| `surchargeType` | Order.attributes.surchargeType (fixed/percentage) |
| `discount` | Order.attributes.discount |
| `discountType` | Order.attributes.discountType |
| `discountDescription` | Order.attributes.discountDescription |
| `createdAt` | Order.attributes.createdAt |
| `updatedAt` | Order.attributes.updatedAt |

**`DL_ORDER_ITEMS`** — Line items within orders

| Column | Mews API Source |
|---|---|
| `id` | OrderItem.id |
| `orderId` | Parent Order.id |
| `outletId` | Parent Order.relationships.outlet.data.id |
| `productId` | OrderItem.relationships.product.data.id |
| `productVariantId` | OrderItem.relationships.productVariant.data.id |
| `quantity` | OrderItem.attributes.quantity |
| `unitPriceInclTax` | OrderItem.attributes.unitPriceInclTax |
| `subtotal` | OrderItem.attributes.subtotal |
| `tax` | OrderItem.attributes.tax |
| `total` | OrderItem.attributes.total |
| `discount` | OrderItem.attributes.discount |
| `discountType` | OrderItem.attributes.discountType |
| `isComp` | OrderItem.attributes.isComp |
| `isVoid` | OrderItem.attributes.isVoid |
| `compVoidReason` | OrderItem.attributes.compVoidReason |
| `compVoidNotes` | OrderItem.attributes.compVoidNotes |
| `notes` | OrderItem.attributes.notes |

**`DL_ORDER_ITEM_MODIFIERS`** — Modifiers applied to order line items

| Column | Mews API Source |
|---|---|
| `orderItemId` | Parent OrderItem.id |
| `orderId` | Grandparent Order.id |
| `outletId` | Grandparent Order.relationships.outlet.data.id |
| `modifierId` | Modifier.id (relationship reference) |
| `name` | Modifier.attributes.name |
| `price` | Modifier.attributes.price |

**`DL_ORDER_BUNDLES`** — Product bundles within orders

| Column | Mews API Source |
|---|---|
| `id` | OrderBundle.id |
| `orderId` | Parent Order.id |
| `outletId` | Parent Order.relationships.outlet.data.id |
| `productBundleId` | OrderBundle.relationships.productBundle.data.id |
| `quantity` | OrderBundle.attributes.quantity |
| `discount` | OrderBundle.attributes.discount |
| `discountType` | OrderBundle.attributes.discountType |

**`DL_ORDER_PAYMENTS`** — Inline payment records on orders

| Column | Mews API Source |
|---|---|
| `id` | OrderPayment.id |
| `orderId` | Parent Order.id |
| `outletId` | Parent Order.relationships.outlet.data.id |
| `paymentMethodId` | OrderPayment.relationships.paymentMethod.data.id |
| `amount` | OrderPayment.attributes.amount |
| `tipAmount` | OrderPayment.attributes.tipAmount |
| `notes` | OrderPayment.attributes.notes |
| `roomNumber` | OrderPayment.attributes.roomNumber |

### 2.2 Invoices Endpoint (`GET /v1/invoices`) — 3 Tables

**`DL_INVOICES`** — Finalized bills (primary financial record)

| Column | Mews API Source |
|---|---|
| `id` | Invoice.id |
| `orderId` | Invoice.relationships.order.data.id |
| `userId` | Invoice.relationships.user.data.id |
| `registerId` | Invoice.relationships.register.data.id |
| `revenueCenterId` | Invoice.relationships.revenueCenter.data.id |
| `promoCodeId` | Invoice.relationships.promoCode.data.id |
| `originalInvoiceId` | Invoice.relationships.originalInvoice.data.id |
| `cancelled` | Invoice.attributes.cancelled |
| `cancelReason` | Invoice.attributes.cancelReason |
| `description` | Invoice.attributes.description |
| `discount` | Invoice.attributes.discount |
| `discountAmount` | Invoice.attributes.discountAmount |
| `itemDiscountAmount` | Invoice.attributes.itemDiscountAmount |
| `subtotal` | Invoice.attributes.subtotal |
| `tax` | Invoice.attributes.tax |
| `tipAmount` | Invoice.attributes.tipAmount |
| `total` | Invoice.attributes.total |
| `createdAt` | Invoice.attributes.createdAt |
| `updatedAt` | Invoice.attributes.updatedAt |

**`DL_INVOICE_ITEMS`** — Line items on invoices (post-discount/tax totals)

| Column | Mews API Source |
|---|---|
| `id` | InvoiceItem.id |
| `invoiceId` | Parent Invoice.id |
| `productId` | InvoiceItem.relationships.product.data.id |
| `productVariantId` | InvoiceItem.relationships.productVariant.data.id |
| `revenueCenterId` | InvoiceItem.relationships.revenueCenter.data.id |
| `productName` | InvoiceItem.attributes.productName (denormalized) |
| `quantity` | InvoiceItem.attributes.quantity |
| `unitPriceInclTax` | InvoiceItem.attributes.unitPriceInclTax |
| `subtotal` | InvoiceItem.attributes.subtotal |
| `tax` | InvoiceItem.attributes.tax |
| `total` | InvoiceItem.attributes.total |
| `discount` | InvoiceItem.attributes.discount |
| `subtotalInclDiscount` | InvoiceItem.attributes.subtotalInclDiscount |
| `taxInclDiscount` | InvoiceItem.attributes.taxInclDiscount |
| `totalInclDiscount` | InvoiceItem.attributes.totalInclDiscount |
| `isComp` | InvoiceItem.attributes.isComp |
| `isVoid` | InvoiceItem.attributes.isVoid |
| `compVoidReason` | InvoiceItem.attributes.compVoidReason |
| `compVoidNotes` | InvoiceItem.attributes.compVoidNotes |
| `createdAt` | InvoiceItem.attributes.createdAt |
| `updatedAt` | InvoiceItem.attributes.updatedAt |

**`DL_INVOICE_ITEM_MODIFIERS`** — Modifiers on invoice line items

| Column | Mews API Source |
|---|---|
| `id` | InvoiceItemModifier.id |
| `invoiceItemId` | Parent InvoiceItem.id |
| `invoiceId` | Grandparent Invoice.id |
| `name` | InvoiceItemModifier.attributes.name |
| `price` | InvoiceItemModifier.attributes.price |

### 2.3 Products & Catalog — 6 Tables

**`DL_PRODUCT_TYPES`** — Product category/type (TOP hierarchy)

| Column | Mews API Source |
|---|---|
| `id` | ProductType.id |
| `name` | ProductType.attributes.name |
| `createdAt` | ProductType.attributes.createdAt |
| `updatedAt` | ProductType.attributes.updatedAt |

**`DL_PRODUCTS`** — Menu items (MIDDLE_1 hierarchy)

| Column | Mews API Source |
|---|---|
| `id` | Product.id |
| `productTypeId` | Product.relationships.productType.data.id |
| `name` | Product.attributes.name |
| `description` | Product.attributes.description |
| `sku` | Product.attributes.sku |
| `barcode` | Product.attributes.barcode |
| `status` | Product.attributes.status (active/inactive) |
| `isAvailable` | Product.attributes.isAvailable |
| `retailPriceExclTax` | Product.attributes.retailPriceExclTax |
| `retailPriceInclTax` | Product.attributes.retailPriceInclTax |
| `tax` | Product.attributes.tax |
| `createdAt` | Product.attributes.createdAt |
| `updatedAt` | Product.attributes.updatedAt |

**`DL_PRODUCT_VARIANTS`** — Size/variant records (BOTTOM hierarchy)

| Column | Mews API Source |
|---|---|
| `id` | ProductVariant.id |
| `productId` | Parent Product.id |
| `sku` | ProductVariant.attributes.sku |
| `barcode` | ProductVariant.attributes.barcode |
| `retailPriceExclTax` | ProductVariant.attributes.retailPriceExclTax |
| `retailPriceInclTax` | ProductVariant.attributes.retailPriceInclTax |
| `selector` | ProductVariant.attributes.selector (raw JSON) |
| `createdAt` | ProductVariant.attributes.createdAt |
| `updatedAt` | ProductVariant.attributes.updatedAt |

**`DL_MODIFIER_SETS`** — Modifier group containers (TOP hierarchy)

| Column | Mews API Source |
|---|---|
| `id` | ModifierSet.id |
| `name` | ModifierSet.attributes.name |
| `selection` | ModifierSet.attributes.selection (single/multiple) |
| `minimumCount` | ModifierSet.attributes.minimumCount |
| `maximumCount` | ModifierSet.attributes.maximumCount |
| `createdAt` | ModifierSet.attributes.createdAt |
| `updatedAt` | ModifierSet.attributes.updatedAt |

**`DL_MODIFIERS`** — Individual modifiers (BOTTOM hierarchy)

| Column | Mews API Source |
|---|---|
| `id` | Modifier.id |
| `modifierSetId` | Parent ModifierSet.id |
| `name` | Modifier.attributes.name |
| `price` | Modifier.attributes.price |
| `createdAt` | Modifier.attributes.createdAt |
| `updatedAt` | Modifier.attributes.updatedAt |

**`DL_PRODUCT_BUNDLES`** — Combo/bundle products

| Column | Mews API Source |
|---|---|
| `id` | ProductBundle.id |
| `name` | ProductBundle.attributes.name |
| `description` | ProductBundle.attributes.description |
| `imageUrl` | ProductBundle.attributes.imageUrl |
| `retailPriceInclTax` | ProductBundle.attributes.retailPriceInclTax |
| `priceRangeMin` | ProductBundle.attributes.priceRange.min |
| `priceRangeMax` | ProductBundle.attributes.priceRange.max |

### 2.4 Venues & Physical Layout — 4 Tables

**`DL_OUTLETS`** — Physical locations/stores

| Column | Mews API Source |
|---|---|
| `id` | Outlet.id |
| `name` | Outlet.attributes.name |
| `address1` | Outlet.attributes.address1 |
| `address2` | Outlet.attributes.address2 |
| `city` | Outlet.attributes.city |
| `state` | Outlet.attributes.state |
| `postalCode` | Outlet.attributes.postalCode |
| `index` | Outlet.attributes.index |
| `createdAt` | Outlet.attributes.createdAt |
| `updatedAt` | Outlet.attributes.updatedAt |

**`DL_AREAS`** — Dining areas within outlets

| Column | Mews API Source |
|---|---|
| `id` | Area.id |
| `name` | Area.attributes.name |
| `isActive` | Area.attributes.isActive |
| `createdAt` | Area.attributes.createdAt |
| `updatedAt` | Area.attributes.updatedAt |

**`DL_TABLES`** — Restaurant tables

| Column | Mews API Source |
|---|---|
| `id` | Table.id |
| `areaId` | Table.relationships.area.data.id |
| `name` | Table.attributes.name |
| `numberOfSeats` | Table.attributes.numberOfSeats |
| `createdAt` | Table.attributes.createdAt |
| `updatedAt` | Table.attributes.updatedAt |

**`DL_REGISTERS`** — POS terminals

| Column | Mews API Source |
|---|---|
| `id` | Register.id |
| `outletId` | Register.relationships.outlet.data.id |
| `name` | Register.attributes.name |
| `invoicesCount` | Register.attributes.invoicesCount |
| `index` | Register.attributes.index |
| `virtual` | Register.attributes.virtual |
| `createdAt` | Register.attributes.createdAt |
| `updatedAt` | Register.attributes.updatedAt |

### 2.5 Customers — 1 Table

**`DL_CUSTOMERS`** — Guest profiles

| Column | Mews API Source |
|---|---|
| `id` | Customer.id |
| `fullName` | Customer.attributes.fullName |
| `companyName` | Customer.attributes.companyName |
| `email` | Customer.attributes.email |
| `phone` | Customer.attributes.phone |
| `mobile` | Customer.attributes.mobile |
| `taxNumber` | Customer.attributes.taxNumber |
| `dateOfBirth` | Customer.attributes.dateOfBirth |
| `notes` | Customer.attributes.notes |
| `address1` | Customer.attributes.address1 |
| `address2` | Customer.attributes.address2 |
| `city` | Customer.attributes.city |
| `state` | Customer.attributes.state |
| `postalCode` | Customer.attributes.postalCode |
| `country` | Customer.attributes.country |
| `countrySpecificCode` | Customer.attributes.countrySpecificCode |
| `createdAt` | Customer.attributes.createdAt |
| `updatedAt` | Customer.attributes.updatedAt |

### 2.6 Bookings — 1 Table

**`DL_BOOKINGS`** — Table reservations

| Column | Mews API Source |
|---|---|
| `id` | Booking.id |
| `customerId` | Booking.relationships.customer.data.id |
| `status` | Booking.attributes.status (confirmed/seated/completed/cancelled/no_show) |
| `partySize` | Booking.attributes.partySize |
| `bookingDatetime` | Booking.attributes.bookingDatetime |
| `duration` | Booking.attributes.duration (minutes) |
| `notes` | Booking.attributes.notes |
| `roomNumber` | Booking.attributes.roomNumber |
| `promotions` | Booking.attributes.promotions |
| `bookingReference` | Booking.attributes.bookingReference |
| `depositAmount` | Booking.attributes.depositAmount |
| `isWalkIn` | Booking.attributes.isWalkIn |
| `createdAt` | Booking.attributes.createdAt |
| `updatedAt` | Booking.attributes.updatedAt |

### 2.7 Reference Data — 4 Tables

**`DL_REVENUE_CENTERS`** — Revenue segmentation

| Column | Mews API Source |
|---|---|
| `id` | RevenueCenter.id |
| `name` | RevenueCenter.attributes.name |
| `isActive` | RevenueCenter.attributes.isActive |
| `createdAt` | RevenueCenter.attributes.createdAt |
| `updatedAt` | RevenueCenter.attributes.updatedAt |

**`DL_PAYMENT_METHODS`** — Payment type definitions

| Column | Mews API Source |
|---|---|
| `id` | PaymentMethod.id |
| `name` | PaymentMethod.attributes.name |
| `code` | PaymentMethod.attributes.code (cash/credit_card/custom/cheque/wire_transfer/paypal/room_charge/voucher/loyalty/etc.) |
| `isActive` | PaymentMethod.attributes.isActive |
| `isTippable` | PaymentMethod.attributes.isTippable |
| `createdAt` | PaymentMethod.attributes.createdAt |
| `updatedAt` | PaymentMethod.attributes.updatedAt |

**`DL_PROMO_CODES`** — Discount/promotional codes

| Column | Mews API Source |
|---|---|
| `id` | PromoCode.id |
| `code` | PromoCode.attributes.code |
| `active` | PromoCode.attributes.active |
| `description` | PromoCode.attributes.description |
| `maxUsages` | PromoCode.attributes.maxUsages |
| `amount` | PromoCode.attributes.amount |
| `discountType` | PromoCode.attributes.discountType (absolute/percent/free_shipping) |
| `channel` | PromoCode.attributes.channel (all_channels/ecommerce/pos) |
| `startsAt` | PromoCode.attributes.startsAt |
| `endsAt` | PromoCode.attributes.endsAt |
| `createdAt` | PromoCode.attributes.createdAt |
| `updatedAt` | PromoCode.attributes.updatedAt |

**`DL_TAXES`** — Tax rate definitions

| Column | Mews API Source |
|---|---|
| `id` | Tax.id |
| `name` | Tax.attributes.name |
| `rate` | Tax.attributes.rate (decimal multiplier) |
| `ratePercent` | Tax.attributes.ratePercent (percentage string) |
| `taxType` | Tax.attributes.taxType (vat/other/fixed/consumption/sales/state/city/liquor/food/entertainment) |
| `isActive` | Tax.attributes.isActive |
| `label` | Tax.attributes.label |
| `createdAt` | Tax.attributes.createdAt |
| `updatedAt` | Tax.attributes.updatedAt |

### 2.8 Menus — 1 Table

**`DL_MENUS`** — Menu configuration (reference only)

| Column | Mews API Source |
|---|---|
| `id` | Menu.id |
| `name` | Menu.attributes.name |
| `status` | Menu.attributes.status (active/inactive) |
| `description` | Menu.attributes.description |
| `deleted` | Menu.attributes.deleted |
| `availabilityDays` | Menu.attributes.availabilityDays (JSON array) |
| `availabilityStartTime` | Menu.attributes.availabilityStartTime |
| `availabilityEndTime` | Menu.attributes.availabilityEndTime |
| `createdAt` | Menu.attributes.createdAt |
| `updatedAt` | Menu.attributes.updatedAt |

### 2.9 Complete Table Index

| # | Table | Endpoint | Parent FK |
|---|---|---|---|
| 1 | `DL_ORDERS` | `GET /v1/orders` | — |
| 2 | `DL_ORDER_ITEMS` | `GET /v1/orders` (items include) | `orderId` |
| 3 | `DL_ORDER_ITEM_MODIFIERS` | `GET /v1/orders` (items→modifiers) | `orderItemId` |
| 4 | `DL_ORDER_BUNDLES` | `GET /v1/orders` (bundles include) | `orderId` |
| 5 | `DL_ORDER_PAYMENTS` | `GET /v1/orders` (payments include) | `orderId` |
| 6 | `DL_INVOICES` | `GET /v1/invoices` | — |
| 7 | `DL_INVOICE_ITEMS` | `GET /v1/invoices` (invoiceItems) | `invoiceId` |
| 8 | `DL_INVOICE_ITEM_MODIFIERS` | `GET /v1/invoices` (items→modifiers) | `invoiceItemId` |
| 9 | `DL_PRODUCT_TYPES` | `GET /v1/products` (include) | — |
| 10 | `DL_PRODUCTS` | `GET /v1/products` | — |
| 11 | `DL_PRODUCT_VARIANTS` | `GET /v1/products` (variants) | `productId` |
| 12 | `DL_MODIFIER_SETS` | `GET /v1/modifier-sets` | — |
| 13 | `DL_MODIFIERS` | `GET /v1/modifier-sets` (modifiers) | `modifierSetId` |
| 14 | `DL_PRODUCT_BUNDLES` | `GET /v1/product-bundles` | — |
| 15 | `DL_OUTLETS` | `GET /v1/outlets` | — |
| 16 | `DL_AREAS` | `GET /v1/areas` | — |
| 17 | `DL_TABLES` | `GET /v1/tables` | `areaId` |
| 18 | `DL_REGISTERS` | `GET /v1/registers` | `outletId` |
| 19 | `DL_CUSTOMERS` | `GET /v1/customers` | — |
| 20 | `DL_BOOKINGS` | `GET /v1/bookings` | — |
| 21 | `DL_REVENUE_CENTERS` | `GET /v1/revenue-centers` | — |
| 22 | `DL_PAYMENT_METHODS` | (reference — sideloaded) | — |
| 23 | `DL_PROMO_CODES` | `GET /v1/promo-codes` | — |
| 24 | `DL_TAXES` | (reference — sideloaded) | — |
| 25 | `DL_MENUS` | `GET /v1/menus` | — |
| 26 | `DL_PAYMENTS` | `POST /v1/payments` (list) | `orderId` |

### Not Included

| Endpoint | Reason |
|---|---|
| Webhook Endpoints | Operational config — no analytical value |
| Space Codes | QR code definitions — no transactional content |
| System (health checks) | Infrastructure only |
| Menu Sections / Menu Items | UI configuration metadata; product→menu link derivable from DL_PRODUCTS |

---

## 3. Staging Steps

All steps use the standard idempotent `DROP TABLE IF EXISTS` + `SELECT INTO` pattern. Output tables in `stage.*` schema with `BIZ_` prefix.

### 3.1 Tier 1 — Base Staging from DL Tables (24 Steps)

#### POS Dimensions (8 steps)

**Step 1: Location** → `BIZ_LOCATION` from `DL_OUTLETS`
- `ITEM_SRC_KEY = id`
- `LOCATION_NAME = name`, `LOCATION_ID = id`
- `LEVEL_NAME = 'BOTTOM'`, `BOTTOM_LEVEL = 1`, `PARENT_ID = NULL`
- `MICROSERVICE_NAME = NULL`, `MICROSERVICE_ID = NULL`
- Dedup: `ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) = 1`

**Step 2: Product Hierarchy** → `BIZ_PRODUCT` from `DL_PRODUCT_VARIANTS` + `DL_PRODUCTS` + `DL_PRODUCT_TYPES`
- Three-level hierarchy via UNION ALL:
  - ProductVariant (BOTTOM): `ITEM_SRC_KEY = pv.id`, `PRODUCT_NAME = COALESCE(pv.selector, pv.sku, pv.id)`, `PARENT_ID = pv.productId`, `LEVEL_NAME = 'BOTTOM'`, `BOTTOM_LEVEL = 1`
  - Product (MIDDLE_1): `ITEM_SRC_KEY = p.id`, `PRODUCT_NAME = p.name`, `PARENT_ID = p.productTypeId`, `LEVEL_NAME = 'MIDDLE_1'`, `BOTTOM_LEVEL = 0`
  - ProductType (TOP): `ITEM_SRC_KEY = pt.id`, `PRODUCT_NAME = pt.name`, `PARENT_ID = NULL`, `LEVEL_NAME = 'TOP'`, `BOTTOM_LEVEL = 0`
- Filter: `WHERE status != 'inactive' OR status IS NULL`
- Dedup per level: `ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) = 1`
- `MICROSERVICE_NAME = NULL`, `MICROSERVICE_ID = NULL`

**Step 3: Modifier Hierarchy** → `BIZ_MODIFIER` from `DL_MODIFIERS` + `DL_MODIFIER_SETS`
- Two-level hierarchy via UNION ALL:
  - Modifier (BOTTOM): `ITEM_SRC_KEY = m.id`, `MOD_NAME = m.name`, `PARENT_ID = m.modifierSetId`, `LEVEL_NAME = 'BOTTOM'`, `BOTTOM_LEVEL = 1`
  - ModifierSet (TOP): `ITEM_SRC_KEY = ms.id`, `MOD_NAME = ms.name`, `PARENT_ID = NULL`, `LEVEL_NAME = 'TOP'`, `BOTTOM_LEVEL = 0`
- `MICROSERVICE_NAME = NULL`, `MICROSERVICE_ID = NULL`

**Step 4: Tax** → `BIZ_TAX` from `DL_TAXES`
- `ITEM_SRC_KEY = id`
- `TAX_NAME = name`, `TAX_ID = id`
- `TAX_MULTIPLIER = CAST(ratePercent AS DECIMAL(18,6)) / 100.0`
- `LEVEL_NAME = 'BOTTOM'`, `PARENT_ID = NULL`
- Filter: `WHERE isActive = 'true'`

**Step 5: Tender** → `BIZ_TENDER` from `DL_PAYMENT_METHODS`
- `ITEM_SRC_KEY = id`
- `TENDER_NAME = name`, `TENDER_ID = id`
- `LEVEL_NAME = 'BOTTOM'`, `PARENT_ID = NULL`, `BOTTOM_LEVEL = 1`
- Filter: `WHERE isActive = 'true'`

**Step 6: Discount** → `BIZ_DISCOUNT` from `DL_PROMO_CODES`
- `ITEM_SRC_KEY = id`
- `DISCOUNT_NAME = COALESCE(description, code)`, `DISCOUNT_ID = id`
- `VALUE_TYPE = discountType`, `VALUE = CAST(amount AS DECIMAL(18,2))`
- `IS_WASTE = 0`
- `LEVEL_NAME = 'BOTTOM'`, `PARENT_ID = NULL`

**Step 7: Channel** → `BIZ_CHANNEL` from `DL_AREAS`
- `ITEM_SRC_KEY = id`
- `CHANNEL_NAME = name`, `CHANNEL_ID = id`
- `LEVEL_NAME = 'BOTTOM'`, `BOTTOM_LEVEL = 1`
- Filter: `WHERE isActive = 'true'`
- Synthetic fallback: `UNION ALL SELECT 'NO_AREA', 'No Area', 'NO_AREA', 'BOTTOM', 1, NULL`

**Step 8: Service Charge** → `BIZ_SERVICECHARGE` — derived from order-level surcharge fields
- `SELECT DISTINCT surchargeType AS SVC_NAME`
- `ITEM_SRC_KEY = surchargeType`, `SVCCHARGE_NAME = surchargeType`, `SVC_ID = surchargeType`
- `LEVEL_NAME = 'BOTTOM'`, `PARENT_ID = NULL`

**Step 9: Revenue Center** → `BIZ_REVCENTER` from `DL_REVENUE_CENTERS`
- `ITEM_SRC_KEY = id`
- `REVC_NAME = name`, `REVC_ID = id`
- `LEVEL_NAME = 'BOTTOM'`, `PARENT_ID = NULL`, `BOTTOM_LEVEL = 1`
- Filter: `WHERE isActive = 'true'`
- Dedup: `ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) = 1`

#### POS Transactional (8 steps)

**Step 10: Customer Order** → `BIZ_CUSTORDER` from `DL_INVOICES` JOIN `DL_ORDERS` JOIN `DL_REGISTERS`
- `HEADER_ID = CONCAT_WS('-', reg.outletId, inv.id)`
- Financial totals from Invoice: `GRAND_TOTAL = CAST(inv.total AS DECIMAL(18,2))`, `GROSS_SALES = CAST(inv.subtotal AS DECIMAL(18,2))`, `TAX_TOTAL = CAST(inv.tax AS DECIMAL(18,2))`, `DISCOUNT_GROSS = CAST(COALESCE(inv.discountAmount, '0') AS DECIMAL(18,2))`
- `NET_SALES = CAST(inv.subtotal AS DECIMAL(18,2)) - CAST(COALESCE(inv.discountAmount, '0') AS DECIMAL(18,2))`
- Metadata from Order: `GUEST_COUNT = CAST(ord.covers AS INT)`, `ORDER_STATUS = ord.state`, `TABLE_NO` from Order→Tables join
- `TRADING_DATE = CAST(COALESCE(inv.createdAt, ord.createdAt) AS DATE)`
- `OPEN_TIME = CAST(ord.createdAt AS DATETIME2)`, `CLOSE_TIME = CAST(inv.createdAt AS DATETIME2)`
- `EXTERNAL_REFERENCE = ord.bookingId`
- `PAYMENT_STATUS = CASE WHEN inv.cancelled = 'true' THEN 'CANCELLED' ELSE 'PAID' END`
- Filter: `WHERE inv.cancelled != 'true' OR inv.cancelled IS NULL`
- Join chain: `DL_INVOICES inv LEFT JOIN DL_ORDERS ord ON inv.orderId = ord.id LEFT JOIN DL_REGISTERS reg ON inv.registerId = reg.id`

**Step 11: Line Item (PROD)** → `BIZ_LINEITEM` from `DL_INVOICE_ITEMS` JOIN `DL_INVOICES` JOIN `DL_REGISTERS`
- `SRC_KEY = CONCAT_WS('-', reg.outletId, ii.invoiceId, ii.id, 'PROD')`
- `HEADER_ID = CONCAT_WS('-', reg.outletId, ii.invoiceId)`
- `LINEITEM_TYPE = 'PROD'`
- `GROSS_VALUE = CAST(ii.totalInclDiscount AS DECIMAL(18,2))`
- `TAX_VALUE = CAST(ii.taxInclDiscount AS DECIMAL(18,2))`
- `NET_VALUE = CAST(ii.subtotalInclDiscount AS DECIMAL(18,2))`
- `QUANTITY = CAST(ii.quantity AS DECIMAL(18,4))`
- `VOID_FLAG = CASE WHEN ii.isVoid = 'true' OR ii.isComp = 'true' THEN 1 ELSE 0 END`
- `LINE_ID = ii.id`, `LINE_ORDER = ROW_NUMBER() OVER (PARTITION BY ii.invoiceId ORDER BY ii.id)`
- `PRODUCT_SRC_KEY = COALESCE(ii.productVariantId, ii.productId)`

**Step 12: Line Item (MOD)** → `BIZ_LINEITEM_MOD` from `DL_INVOICE_ITEM_MODIFIERS` + joins
- `SRC_KEY = CONCAT_WS('-', reg.outletId, iim.invoiceId, iim.invoiceItemId, iim.id, 'MOD')`
- `PARENT_SRC_KEY = CONCAT_WS('-', reg.outletId, ii.invoiceId, ii.id, 'PROD')`
- `LINEITEM_TYPE = 'MOD'`, `GROSS_VALUE = CAST(iim.price AS DECIMAL(18,2))`
- `MOD_SRC_KEY = iim.modifierId` (if available) or derived from `DL_MODIFIERS` lookup

**Step 13: Line Item (TAX)** → `BIZ_LINEITEM_TAX` from `DL_INVOICE_ITEMS`
- `SRC_KEY = CONCAT_WS('-', reg.outletId, ii.invoiceId, ii.id, 'TAX')`
- `LINEITEM_TYPE = 'TAX'`, `GROSS_VALUE = CAST(ii.taxInclDiscount AS DECIMAL(18,2))`
- Filter: `WHERE CAST(ii.taxInclDiscount AS DECIMAL(18,2)) != 0`

**Step 14: Line Item (DISCOUNT)** → `BIZ_LINEITEM_DISCOUNT` from `DL_INVOICE_ITEMS`
- `SRC_KEY = CONCAT_WS('-', reg.outletId, ii.invoiceId, ii.id, 'DISCOUNT')`
- `LINEITEM_TYPE = 'DISCOUNT'`, `GROSS_VALUE = CAST(ii.discount AS DECIMAL(18,2)) * -1`
- Filter: `WHERE CAST(ii.discount AS DECIMAL(18,2)) != 0 AND ii.discount IS NOT NULL`

**Step 15: Line Item (TENDER)** → `BIZ_LINEITEM_TENDER` from `DL_ORDER_PAYMENTS` JOIN `DL_INVOICES`
- `SRC_KEY = CONCAT_WS('-', reg.outletId, inv.id, op.id, 'TENDER')`
- `LINEITEM_TYPE = 'TENDER'`, `GROSS_VALUE = CAST(op.amount AS DECIMAL(18,2))`
- `TENDER_SRC_KEY = op.paymentMethodId`

**Step 16: Line Item (SVC)** → `BIZ_LINEITEM_SVC` from `DL_ORDERS` (surcharge fields)
- `SRC_KEY = CONCAT_WS('-', ord.outletId, inv.id, 'SVC')`
- `LINEITEM_TYPE = 'SVC'`, `GROSS_VALUE = CAST(ord.surcharge AS DECIMAL(18,2))`
- Filter: `WHERE ord.surcharge IS NOT NULL AND CAST(ord.surcharge AS DECIMAL(18,2)) != 0`

**Step 17: Register Lookup** → `BIZ_REGISTER_LOOKUP` from `DL_REGISTERS`
- Pure reference table: `REGISTER_ID = id`, `OUTLET_ID = outletId`, `REGISTER_NAME = name`
- Used as JOIN source in Steps 10–16 to resolve outletId

#### CRM (1 step)

**Step 18: Customer** → `BIZ_CUSTOMER` from `DL_CUSTOMERS`
- `ITEM_SRC_KEY = id`
- `FIRST_NAME = fullName` (Mews has single fullName field)
- `SURNAME = NULL`, `EMAIL = email`, `PHONE = phone`, `MOBILE = mobile`
- `DOB = dateOfBirth`, address fields pass through
- Dedup: `ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) = 1`

#### Booking (1 step)

**Step 19: Booking** → `BIZ_BOOKING` from `DL_BOOKINGS`
- `ITEM_SRC_KEY = id`
- `CUSTOMER_SRC_KEY = customerId`
- `BOOKING_STATUS = status` (confirmed/seated/completed/cancelled/no_show)
- `PARTY_SIZE = CAST(partySize AS DECIMAL(38,10))`
- `BOOKING_DATETIME = CAST(bookingDatetime AS DATETIME2)`
- `BOOKING_DATE = CAST(bookingDatetime AS DATE)` — time series column
- `DURATION_MINS = CAST(duration AS DECIMAL(38,10))`
- `IS_WALKIN = isWalkIn`
- `DEPOSIT_AMOUNT = CAST(depositAmount AS DECIMAL(38,10))`
- `BOOKING_REFERENCE = bookingReference`
- `ROOM_NUMBER = roomNumber`
- `NOTES = notes`
- Dedup: `ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) = 1`

#### Reference (2 steps)

**Step 20: Table Reference** → `BIZ_TABLE` from `DL_TABLES` JOIN `DL_AREAS`
- Lookup: `TABLE_ID`, `TABLE_NAME`, `AREA_ID`, `AREA_NAME`, `NUMBER_OF_SEATS`

**Step 21: Menu Reference** → `BIZ_MENU` from `DL_MENUS`
- Reference only — no DV mapping

### 3.2 Tier 2 — Link Staging (15 Steps)

| # | Step Name | Staging Table | Link Entity | Sources |
|---|---|---|---|---|
| 1 | Order to Location | `BIZ_CUSTORDER_LOCATION` | CUSTORDER_LOCATION | `BIZ_CUSTORDER` |
| 2 | Order to Channel | `BIZ_CHANNEL_CUSTORDER` | CHANNEL_CUSTORDER | `BIZ_CUSTORDER` + `BIZ_TABLE` |
| 3 | Order to Line Item | `BIZ_CUSTORDER_LINEITEM` | CUSTORDER_LINEITEM | All LINEITEM staging tables |
| 4 | Line Item to Product | `BIZ_LINEITEM_PRODUCT` | LINEITEM_PRODUCT | `BIZ_LINEITEM` |
| 5 | Tax Line to Tax | `BIZ_LINEITEM_TAX_LNK` | LINEITEM_TAX | `BIZ_LINEITEM_TAX` |
| 6 | Discount to Line Item | `BIZ_DISCOUNT_LINEITEM` | DISCOUNT_LINEITEM | `BIZ_LINEITEM_DISCOUNT` |
| 7 | Modifier to Line Item | `BIZ_LINEITEM_MOD_LNK` | LINEITEM_MOD | `BIZ_LINEITEM_MOD` |
| 8 | Tender to Line Item | `BIZ_LINEITEM_TENDER_LNK` | LINEITEM_TENDER | `BIZ_LINEITEM_TENDER` |
| 9 | SvcCharge to Line Item | `BIZ_LINEITEM_SVC_LNK` | LINEITEM_SVCCHARGE | `BIZ_LINEITEM_SVC` |
| 10 | Order to Revenue Center | `BIZ_CUSTORDER_REVCENTER` | CUSTORDER_REVCENTER | `BIZ_CUSTORDER` |
| 11 | Address to Individual | `BIZ_ADDRESS_INDIVIDUAL` | ADDRESS_INDIVIDUAL | `BIZ_CUSTOMER` |
| 12 | Contact to Individual | `BIZ_CONTACT_INDIVIDUAL` | CONTACT_INDIVIDUAL | `BIZ_CUSTOMER` |
| 13 | Booking to Order | `BIZ_BOOKING_CUSTORDER` | BOOKING_CUSTORDER | `BIZ_BOOKING` + `BIZ_CUSTORDER` via `DL_ORDERS.bookingId` |
| 14 | Order to Customer | `BIZ_CUSTORDER_INDIVIDUAL` | (future) | `BIZ_CUSTORDER` + `DL_ORDERS` |
| 15 | Refund to Order | `BIZ_CUSTORDER_REFUND` | CUSTORDER_REFUND | (future refund staging) |

### 3.3 Tier 3 — Self-Referencing Links (1 Step)

**Modifier to Parent Line Item** → `BIZ_LINEITEM_LINEITEM`
- Links MOD-type line items back to their parent PROD-type line item via `PARENT_SRC_KEY`
- `LABEL = MOD_NAME`, `VALUE = GROSS_VALUE`, `INFO = NULL`

---

## 4. Entity Mappings

### 4.1 Hub Mappings (25)

| # | Entity | Source Table | Business Key (hash:1) | Key Satellite Attributes |
|---|---|---|---|---|
| 1 | LOCATION | `BIZ_LOCATION` | `CONCAT_WS('-', outlet_id)` | LOCATION_NAME, LOCATION_ID, LEVEL_NAME='BOTTOM' |
| 2 | PRODUCT | `BIZ_PRODUCT` (variants) | `CONCAT_WS('-', variant_id)` | PRODUCT_NAME, PRODUCT_ID, LEVEL_NAME='BOTTOM', PARENT_ID |
| 3 | PRODUCT | `BIZ_PRODUCT` (products) | `CONCAT_WS('-', product_id)` | LEVEL_NAME='MIDDLE_1' |
| 4 | PRODUCT | `BIZ_PRODUCT` (types) | `CONCAT_WS('-', product_type_id)` | LEVEL_NAME='TOP' |
| 5 | MOD | `BIZ_MODIFIER` (modifiers) | `CONCAT_WS('-', modifier_id)` | MOD_NAME, LEVEL_NAME='BOTTOM' |
| 6 | MOD | `BIZ_MODIFIER` (sets) | `CONCAT_WS('-', modifier_set_id)` | MOD_NAME, LEVEL_NAME='TOP' |
| 7 | TAX | `BIZ_TAX` | `CONCAT_WS('-', tax_id)` | TAX_NAME, TAX_MULTIPLIER |
| 8 | TENDER | `BIZ_TENDER` | `CONCAT_WS('-', payment_method_id)` | TENDER_NAME, TENDER_ID |
| 9 | REVCENTER | `BIZ_REVCENTER` | `CONCAT_WS('-', revenue_center_id)` | REVC_NAME, REVC_ID |
| 10 | CHANNEL | `BIZ_CHANNEL` | `CONCAT_WS('-', area_id)` | CHANNEL_NAME, CHANNEL_ID |
| 11 | DISCOUNT | `BIZ_DISCOUNT` | `CONCAT_WS('-', promo_code_id)` | DISCOUNT_NAME, VALUE_TYPE, VALUE |
| 12 | SVCCHARGE | `BIZ_SERVICECHARGE` | `CONCAT_WS('-', svc_name)` | SVCCHARGE_NAME, SVC_ID |
| 13 | CUSTORDER | `BIZ_CUSTORDER` | `CONCAT_WS('-', outlet_id, invoice_id)` | GRAND_TOTAL, GROSS_SALES, NET_SALES, TAX_TOTAL, DISCOUNT_GROSS, GUEST_COUNT, TABLE_NO, TRADING_DATE, etc. |
| 14 | LINEITEM | `BIZ_LINEITEM` | `SRC_KEY` | LINEITEM_TYPE='PROD', GROSS_VALUE, TAX_VALUE, NET_VALUE, QUANTITY |
| 15 | LINEITEM | `BIZ_LINEITEM_MOD` | `SRC_KEY` | LINEITEM_TYPE='MOD' |
| 16 | LINEITEM | `BIZ_LINEITEM_TAX` | `SRC_KEY` | LINEITEM_TYPE='TAX' |
| 17 | LINEITEM | `BIZ_LINEITEM_DISCOUNT` | `SRC_KEY` | LINEITEM_TYPE='DISCOUNT' |
| 18 | LINEITEM | `BIZ_LINEITEM_TENDER` | `SRC_KEY` | LINEITEM_TYPE='TENDER' |
| 19 | LINEITEM | `BIZ_LINEITEM_SVC` | `SRC_KEY` | LINEITEM_TYPE='SVC' |
| 20 | BOOKING | `BIZ_BOOKING` | `CONCAT_WS('-', booking_id)` | BOOKING_STATUS, PARTY_SIZE, BOOKING_DATETIME, BOOKING_DATE, DURATION_MINS, IS_WALKIN, DEPOSIT_AMOUNT, BOOKING_REFERENCE, ROOM_NUMBER, NOTES |
| 21 | INDIVIDUAL | `BIZ_CUSTOMER` | `CONCAT_WS('-', customer_id)` | FORENAME=fullName, SURNAME=NULL |
| 22 | ADDRESS | `BIZ_CUSTOMER` | `CONCAT_WS('-', customer_id, 'HOME')` | ADDRESS, POSTCODE, COUNTRY |
| 23 | CONTACT | `BIZ_CUSTOMER` | `CONCAT_WS('-', customer_id, 'EMAIL')` | CONTACT=email, CONTACT_TYPE='EMAIL' |
| 24 | CONTACT | `BIZ_CUSTOMER` | `CONCAT_WS('-', customer_id, 'PHONE')` | CONTACT=phone, CONTACT_TYPE='PHONE' |

*25 rows due to PRODUCT (3 levels), MOD (2 levels), LINEITEM (6 types), CONTACT (2 types). 17 unique entity names.*

### 4.2 Link Mappings (15)

| # | Entity | Source Table | Hub Keys |
|---|---|---|---|
| 1 | CUSTORDER_LOCATION | `BIZ_CUSTORDER_LOCATION` | CUSTORDER_HUB_ID, LOCATION_HUB_ID |
| 2 | CHANNEL_CUSTORDER | `BIZ_CHANNEL_CUSTORDER` | CHANNEL_HUB_ID, CUSTORDER_HUB_ID |
| 3 | CUSTORDER_LINEITEM | `BIZ_CUSTORDER_LINEITEM` | CUSTORDER_HUB_ID, LINEITEM_HUB_ID |
| 4 | LINEITEM_PRODUCT | `BIZ_LINEITEM_PRODUCT` | LINEITEM_HUB_ID, PRODUCT_HUB_ID |
| 5 | LINEITEM_TAX | `BIZ_LINEITEM_TAX_LNK` | LINEITEM_HUB_ID, TAX_HUB_ID |
| 6 | DISCOUNT_LINEITEM | `BIZ_DISCOUNT_LINEITEM` | DISCOUNT_HUB_ID, LINEITEM_HUB_ID |
| 7 | LINEITEM_MOD | `BIZ_LINEITEM_MOD_LNK` | LINEITEM_HUB_ID, MOD_HUB_ID |
| 8 | LINEITEM_TENDER | `BIZ_LINEITEM_TENDER_LNK` | LINEITEM_HUB_ID, TENDER_HUB_ID |
| 9 | LINEITEM_SVCCHARGE | `BIZ_LINEITEM_SVC_LNK` | LINEITEM_HUB_ID, SVCCHARGE_HUB_ID |
| 10 | LINEITEM_LINEITEM | `BIZ_LINEITEM_LINEITEM` | LINEITEM_HUB_ID (parent), LINEITEM_HUB_ID (child) |
| 11 | CUSTORDER_REVCENTER | `BIZ_CUSTORDER_REVCENTER` | CUSTORDER_HUB_ID, REVCENTER_HUB_ID |
| 12 | BOOKING_CUSTORDER | `BIZ_BOOKING_CUSTORDER` | BOOKING_HUB_ID, CUSTORDER_HUB_ID |
| 13 | ADDRESS_INDIVIDUAL | `BIZ_ADDRESS_INDIVIDUAL` | ADDRESS_HUB_ID, INDIVIDUAL_HUB_ID |
| 14 | CONTACT_INDIVIDUAL | `BIZ_CONTACT_INDIVIDUAL` | CONTACT_HUB_ID, INDIVIDUAL_HUB_ID |
| 15 | CUSTORDER_REFUND | `BIZ_CUSTORDER_REFUND` | CUSTORDER_HUB_ID, REFUND_HUB_ID |

### 4.3 Totals

- **Hub mapping rows:** 25 (17 unique entity names)
- **Link mapping rows:** 15
- **Total:** 40 entity mapping records
- **New DV entities:** 2 (BOOKING v2 Live hub, BOOKING_CUSTORDER Live link)

### 4.4 New Data Vault Entity Definitions

Two new entity records are required in `8_DataVaultEntities.sql`. The existing Build-state `BOOKING` (v1) and `ASSET_BOOKING_CUSTORDER` (v1) are left unchanged — the new entities supersede them for this integration.

#### BOOKING v2 (Live Hub)

```
ENTITY_NAME:        BOOKING
VERSION:            2
RELEASE_STATE:      Live
SPLIT_MAP:          1
PRIMARY_SOURCE_TYPE: PoS
TIME_SERIES:        1
TIME_SERIES_COLUMN: BOOKING_DATE
DESCRIPTION:        Table/space reservations from POS systems (Mews bookings)

ATTRIBUTE_NAMES:
  BOOKING_STATUS        NVARCHAR(255)   — confirmed/seated/completed/cancelled/no_show
  PARTY_SIZE            DECIMAL(38,10)  — number of guests
  BOOKING_DATETIME      DATETIME2(7)    — scheduled reservation date/time
  BOOKING_DATE          DATETIME2(7)    — business date (time series column)
  DURATION_MINS         DECIMAL(38,10)  — reservation duration in minutes
  IS_WALKIN             NVARCHAR(255)   — walk-in flag (true/false)
  DEPOSIT_AMOUNT        DECIMAL(38,10)  — deposit paid
  BOOKING_REFERENCE     NVARCHAR(255)   — external booking reference
  ROOM_NUMBER           NVARCHAR(255)   — hotel room number (if applicable)
  NOTES                 NVARCHAR(MAX)   — free-text notes
```

#### BOOKING_CUSTORDER (Live Binary Link)

```
ENTITY_NAME:        BOOKING_CUSTORDER
VERSION:            1
RELEASE_STATE:      Live
SPLIT_MAP:          1_1
PRIMARY_SOURCE_TYPE: NULL
TIME_SERIES:        0
TIME_SERIES_COLUMN: NULL
DESCRIPTION:        Link connecting BOOKING to CUSTORDER (reservation to invoice)

ATTRIBUTE_NAMES:    []  (no SAT_LNK attributes)
ATTRIBUTE_TYPES:    []
```

**Note:** The existing Build-state `ASSET_BOOKING_CUSTORDER` (ternary: ASSET + BOOKING + CUSTORDER) is designed for hotel room/resource bookings. The new `BOOKING_CUSTORDER` (binary) is specifically for POS table reservations where the ASSET concept is not needed. Both can coexist — the ternary can be activated later if hotel asset tracking is required.

---

## 5. Presentation Layer Impact Assessment

### 5.1 Tables Receiving Bizon Data Automatically — No Changes

| Table | Tier | Impact |
|---|---|---|
| D_PRODUCT | 1 | ProductType→Product→Variant fills BOTTOM/MIDDLE_1/TOP hierarchy |
| D_LOCATION | 1 | Outlets populate dimension |
| D_CHANNEL | 1 | Areas (Bar, Terrace, etc.) appear as channels |
| D_OCCASION | 1 | Revenue Centers appear as occasions |
| D_TAX | 1 | Tax profiles populate dimension |
| D_DISCOUNT | 1 | Promo codes populate dimension |
| D_MOD | 1 | Modifiers populate 2-level hierarchy |
| D_SERVICECHARGE | 1 | Surcharge types populate dimension |
| D_TENDER | 1 | Payment methods populate dimension |
| CALENDAR | 1 | No impact |
| F_LINEITEM_15MIN | 2 | Core POS fact — all line item types join all dimension links |
| F_PRODUCT_MARGIN_DAY | 2 | Revenue columns populated; NET_COST = NULL |
| E_COOCCUR_BASE | 2 | Works unchanged |
| D_COOCCURRENCE | 2 | Works unchanged |
| FORECAST_ACTUALS_BASE | 2 | Works unchanged |

### 5.2 Known Gaps

| Gap | Impact | When to Address |
|---|---|---|
| F_PRODUCT_MARGIN_DAY NET_COST = NULL | No margin analytics for Bizon-only orgs | If paired with MarketMan/Growyze inventory integration |
| DimCustomer not connected | Customer data lands in DV but no PresentationControl bridge | When CRM dashboard is designed |
| BOOKING presentation table | BOOKING data lands in DV but no PresentationControl step or vis queries for bookings yet | When booking analytics dashboard is designed |
| `closed` invoice status | Unclear if `closed` = paid or deferred hotel billing — excluded from staging filter until confirmed | When sample data is available for evaluation |

---

## 6. Gap Analysis & Risk Assessment

### 6.1 CRITICAL: Orders vs Invoices (Double-Counting Prevention)

**Decision: Use Invoices as the CUSTORDER source.**

- Invoice = finalized bill with accurate totals and payment status
- Order = operational record (covers, table, booking, state)
- CUSTORDER business key = `invoice_id` (not `order_id`)
- Split-bill: 2 invoices from 1 order → 2 CUSTORDER records, each carrying the **full** `covers` count from the parent Order (no division — see §1 Key Design Decisions)
- Filter: `WHERE inv.cancelled != 'true' OR inv.cancelled IS NULL`
- **`closed` status:** meaning is unconfirmed — may be deferred hotel billing. Start with `status = 'paid'` only. Revisit when sample data available.

**Risk if Orders used instead:** double-counting line items, missing payment data, leaking open orders.

### 6.2 New Entity Analysis

| Concept | Decision | Rationale |
|---|---|---|
| BOOKING | **New Live entity (v2)** | Mews bookings are first-class. BOOKING hub + BOOKING_CUSTORDER link. See §4.4 for entity definitions |
| Areas | → CHANNEL hub | Spatial sub-outlet grouping. No new entity needed |
| Tables | → CUSTORDER.TABLE_NO | Existing attribute. No new entity |
| Revenue Centers | → REVCENTER hub | Direct mapping to existing entity. **Not OCCASION** — revenue centers are financial segmentation, not service occasion |
| Registers | → Not mapped | DL table only. No entity demand |
| Product Bundles | → LINEITEM_LINEITEM self-ref | Bundle parent→component via self-referencing link. DEAL entity not activated |
| Allergens | → Not mapped | No vis queries, no entity. Future satellite attribute |
| Workforce | → Not mapped | Mews POS API has no timeclock/shift endpoints. Removed from scope |

### 6.3 Fetcher Impact: JSON:API Format

**HIGH RISK — the fetcher team will need to build a new JSON:API unravel method.**

This is a prerequisite for the entire integration. The existing fetcher supports plain REST JSON (NCRAloha, Square). Mews uses JSON:API (`application/vnd.api+json`) which has fundamentally different response structure:

| Feature | Impact |
|---|---|
| `data` + `included` sideloading | Related objects in separate `included` array. Fetcher must correlate by type+id |
| `relationships` object | FKs declared by reference, not embedded inline |
| `attributes` wrapper | All fields under `data[i].attributes.field_name` |
| `include` query parameter | Must explicitly request relationships per API call |
| Cursor pagination | UUID-based cursors (`page[after]`), not token-based |

**Action required:** Fetcher team to design and implement a JSON:API unravel strategy. This may be reusable for any future JSON:API-based integration. The `APIEndpointDetail` JSON configuration schema may need extending to describe JSON:API-specific extraction patterns (sideloaded types, relationship resolution).

### 6.4 Data Quality Risks

| Risk | Severity | Mitigation |
|---|---|---|
| String decimal parsing | Medium | Use `TRY_CAST(field AS DECIMAL(18,2))` in all monetary staging |
| Timezone / TRADING_DATE | Medium | Outlet timezone available from DL_OUTLETS; apply offset in staging |
| Comp/void interpretation | Low | `isComp` and `isVoid` both set `VOID_FLAG = 1`; comps include in totals with £0 |
| Hotel room charges | Low | `room_charge` maps to TENDER naturally; filterable in D_TENDER |
| Multi-currency | Low (UK focus) | Currency field captured in DL but not used in staging |
| Order state filter | Medium | Start with `status = 'paid'` only; confirm `'closed'` semantics before including |

### 6.5 Cross-Integration Alignment

| Aspect | NCRAloha | Square | Bizon |
|---|---|---|---|
| Financial source | Sales stream (checks) | Orders | **Invoices** |
| Location key | storeId | location_id | **outletId** (via Register) |
| Product hierarchy | Menu→Category→Item | Category→Item→Variation | **ProductType→Product→Variant** |
| Currency handling | Decimal values | Integer / 100 | **String decimal** |
| Revenue Center | Yes (service types) | No | **Yes** (REVCENTER hub) |
| Occasion | Yes | Yes | **Not mapped** |
| Channel concept | Order type | Order source | **Area** |
| Bookings | No | No | **Yes** (BOOKING hub + BOOKING_CUSTORDER) |
| CRM | No | Yes | **Yes** |
| Inventory | No | Optional | **No** (POS-only) |
| Workforce | Yes | Yes | **No** (no API endpoint) |

---

## 7. Open Questions

| # | Question | Impact |
|---|---|---|
| 1 | Does Mews `closed` invoice status mean paid, or deferred hotel billing? | Determines staging filter safety |
| 2 | Are Revenue Centers attached at invoice level? | JOIN strategy in CUSTORDER_OCCASION staging |
| 3 | Does JSON:API `include` support all required relationships? | Fetcher round-trip count |
| 4 | What Bizon client organisations — hotel, restaurant, pub? | Timezone, room charge, occasion handling |
| 5 | Will Bizon orgs have co-deployed inventory integrations? | Cross-domain cost matching timeline |
| 6 | Can existing fetcher handle JSON:API format? | May block MVP |

---

## 8. Implementation Notes

### 8.1 JSON:API Response Format

Mews uses JSON:API (`application/vnd.api+json`), unlike NCRAloha/Square which use plain REST JSON. The response structure is:

```json
{
  "data": [
    {
      "id": "uuid",
      "type": "orders",
      "attributes": { "state": "paid", "covers": 4, ... },
      "relationships": {
        "outlet": { "data": { "type": "outlets", "id": "uuid" } },
        "orderItems": { "data": [{ "type": "orderItems", "id": "uuid" }] }
      }
    }
  ],
  "included": [
    { "id": "uuid", "type": "outlets", "attributes": { "name": "Bar" } },
    { "id": "uuid", "type": "orderItems", "attributes": { "quantity": "2.00" } }
  ]
}
```

The fetcher must: (1) read `attributes` from each data object, (2) resolve relationship IDs to column values, (3) look up sideloaded objects in `included` array.

### 8.2 Incremental Fetch Watermarks

| Endpoint | Filter Parameter | Notes |
|---|---|---|
| Orders | `filter[updatedAtGt]` | Delta on order updates |
| Invoices | `filter[createdAtGt]` | Delta on new invoices |
| Products | `filter[updatedAtGt]` | Delta on product changes |
| Customers | `filter[emailEq]` or cursor | No native time filter; full refresh recommended |
| Bookings | `filter[updatedAtGt]` | Delta on booking changes |

### 8.3 Webhook Events (Future)

6 available webhooks: `productAvailabilityUpdated`, `orderStateUpdated`, `orderStatusUpdated`, `orderTotalUpdated`, `bookingStatusUpdated`, `orderPaymentsAdded`. Could enable near-real-time updates in future but requires webhook receiver infrastructure. Not in MVP scope.

### 8.4 Rate Limiting

Response headers: `X-Rate-Limit-Limit`, `X-Rate-Limit-Remaining`, `X-Rate-Limit-Reset`, `Retry-After` (on 429). Fetcher must respect these during backfill.

---

## 9. Implementation Priority

### MVP — Must-Have

| Component | Entities | Notes |
|---|---|---|
| Outlets | LOCATION | Core POS dimension |
| Products | PRODUCT (3-tier) | Core POS dimension |
| Invoices | CUSTORDER + LINEITEM (6 types) | Core POS fact |
| Payments | TENDER | First/second integration to populate |
| Taxes | TAX | Required for NET vs GROSS |
| Revenue Centers | REVCENTER + CUSTORDER_REVCENTER | Financial segmentation |
| Modifiers | MOD | Product-level accuracy |
| Discounts | DISCOUNT | Financial accuracy |
| Areas/Channels | CHANNEL | Spatial context |
| Service Charges | SVCCHARGE | Surcharge tracking |
| Bookings | BOOKING (new v2) + BOOKING_CUSTORDER | Table reservations — new DV entities |
| CRM | INDIVIDUAL + CONTACT + ADDRESS | Customer analytics |
| Bundles | LINEITEM_LINEITEM self-ref | Combo analytics via self-referencing link |

### Phase 2 — High Value

| Component | Notes |
|---|---|
| Refunds (REFUND, CUSTORDER_REFUND) | Refund tracking |
| Booking presentation layer | PresentationControl steps + vis queries for booking analytics |
| `closed` invoice status | Validate against sample data; potentially expand staging filter |

### Phase 3 — Deferred

| Component | Notes |
|---|---|
| Webhooks | Requires platform infrastructure |
| Allergens/dietary restrictions | No vis queries exist |
| Multi-currency support | No platform currency layer |
| DEAL entity activation | Only if bundle/combo reporting needs dedicated dimension beyond LINEITEM_LINEITEM |

---

## 10. Script File Inventory

| File | Estimated Lines | Contents |
|---|---|---|
| `Bizon/Bizon001_INIT.sql` | ~80 | AddIntegration + IntegrationType + APIEndpointDetail JSON skeleton |
| `Bizon/Bizon001_DDL.sql` | ~700 | 26 DL table CREATE TABLE DDLs as GlobalParameters STAGE_DDL records |
| `Bizon/Bizon001_Staging.sql` | ~2,500–3,000 | 43 StagingControl upserts with full query_sql |
| `Bizon/Bizon001_Mapping.sql` | ~1,200 | 46 EntityMappings upserts |
| `Bizon/Bizon001_Final.sql` | ~10 | `EXEC [core].[UploadEntityMappings] @intSchema = N'int_bizon001'` |

**Estimated total: ~4,500–5,000 lines across 5 files**

### Deployment Order

1. `Bizon001_INIT.sql` — registers integration
2. `sp_CreateIntegrationTables @DatabaseName = 'core', @SchemaName = 'int_bizon001'`
3. `Bizon001_DDL.sql` — DL table definitions into GlobalParameters
4. `Bizon001_Staging.sql` — staging steps into StagingControl
5. `Bizon001_Mapping.sql` — entity mappings into EntityMappings
6. `Bizon001_Final.sql` — generates Load steps from entity mappings

Per-org activation: `EXEC [core].[MapOrganisationToIntegration] @OrganisationID = ?, @IntegrationID = ?`

---

## 11. Comparison with Existing POS Integrations

| Metric | NCRAloha | Square | Bizon |
|---|---|---|---|
| DL tables | 21 | 22 | **26** |
| Staging steps | 27 | 39 | **36** |
| Entity mappings | 34 | 45 | **40** |
| Script lines | ~5,000 | ~5,000 | **~4,500** |
| New DV entities | 0 | 0 | **2** (BOOKING v2, BOOKING_CUSTORDER) |
| Presentation changes | 0 | 0 | **0** |
| Revenue Centers | Yes | No | **Yes** (REVCENTER hub) |
| Occasion | Yes | Yes | **No** (not mapped — no API data) |
| CRM | No | Yes | **Yes** |
| Bookings | No | No | **Yes** (new entity) |
| Inventory | No | Optional | **No** |
| Workforce | Yes | Yes | **No** (no API endpoint) |
