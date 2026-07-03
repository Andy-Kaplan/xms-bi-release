# Mews (Mews001) Data Vault Mapping Design

**Date:** 2026-07-03
**Status:** APPROVED (user-reviewed in session)
**Integration:** `Mews001` / `int_mews001` / IntegrationType `POS` (IntegrationID 8)
**Supersedes:** `ClaudeDevelopment/integrations/Bizon/2026-04-09-bizon-integration-design.md` for staging + mapping scope (the April design remains the reference for DL table intent and API behaviour)
**Test org:** Three Rocks Hotel — OrganisationID 19, DB `20260413_XMS_B4E2F7A8-3C91-4D6E-9F05-8A1D2B5E7C43` (DEV)

---

## 1. Context

The Bizon/Mews POS integration was designed in April 2026 (Bizon001) but deployed by the fetcher team as **Mews001 / `int_mews001`**. Real data has now landed in DEV org 19. This design plans the staging steps and entity mappings that take that data into the Data Vault, revised against **what actually landed** rather than what the April design assumed.

`core.int_mews001.StagingControl` and `core.int_mews001.EntityMappings` exist and are **empty** — this work populates them. All target DV entities already exist as Live entities with tables deployed in org 19. **No DataVaultEntities changes, no DDL, no doc-sync burden in this phase.**

### Landed data snapshot (2026-07-03)

22 of the 26 designed DL tables exist. Populated: DL_OUTLETS (2), DL_REGISTERS (4), DL_PRODUCTS (98), DL_PRODUCT_VARIANTS (181), DL_PRODUCT_TYPES (12), DL_ORDERS (19), DL_ORDER_ITEMS (22), DL_INVOICES (19), DL_INVOICE_ITEMS (22), DL_CUSTOMERS (364), DL_TABLES (100), DL_AREAS (2), DL_PAYMENT_METHODS (6), DL_PROMO_CODES (2), DL_TAXES (1). Empty: DL_BOOKINGS, DL_REVENUE_CENTERS, DL_MODIFIERS, DL_MODIFIER_SETS, DL_ORDER_ITEM_MODIFIERS, DL_MENUS, DL_PRODUCT_BUNDLES.

Join-chain integrity verified: every invoice resolves registerId → outletId; zero orphan products/variants; every sale line carries productId.

### Deltas from the April design (verified against landed schema/data)

| # | Delta | Consequence |
|---|---|---|
| 1 | Integration is `Mews001`/`int_mews001`, not `Bizon001` | All naming switches to Mews (`MEWS_` staging prefix) |
| 2 | `DL_ORDER_PAYMENTS`, `DL_PAYMENTS`, `DL_INVOICE_ITEM_MODIFIERS`, `DL_ORDER_BUNDLES` never landed | No TENDER line-item source; no invoice-modifier source; bundle handling dropped |
| 3 | `DL_ORDERS` has no surcharge/discount columns | SVCCHARGE entity and SVC line items have no source — dropped |
| 4 | `DL_ORDERS` has no tableId | CHANNEL_CUSTORDER link (order→table→area) impossible — CHANNEL is hub-only |
| 5 | `DL_INVOICES` has no `status` column, only `cancelled` | The April `paid` vs `closed` question is moot; filter on `cancelled` |
| 6 | Booleans land as `'0'`/`'1'`, not `'true'`/`'false'` | Every designed filter like `isActive = 'true'` corrected to `= '1'` |
| 7 | `DL_INVOICE_ITEMS` lacks `subtotalInclDiscount`/`taxInclDiscount`/`totalInclDiscount` | Line values map from plain `subtotal`/`tax`/`total` |
| 8 | 52 of 98 products have no variants; 19 of 22 invoice items reference product level | Strict variant=BOTTOM hierarchy would orphan most sales — see §3 |
| 9 | All 19 orders are `state='paid'`; amounts are string decimals; timestamps ISO 8601 with `Z` | As designed (CAST AS DECIMAL(18,2), no division) |

## 2. Decisions

1. **Scope: everything with a DL table present.** Steps against empty-but-present tables (MOD hubs, REVCENTER, CHANNEL) are included and produce 0 rows until data arrives. Steps whose source table does not exist (TENDER lines, SVC, invoice modifiers) are excluded.
2. **BOOKING deferred.** DL_BOOKINGS is empty and no order references a booking. The BOOKING v2 hub + BOOKING_CUSTORDER link entities are NOT created now; no BOOKING staging step. Follow-up release when Mews bookings flow. (The Live `BOOKINGREPORT` entity that appeared since April is an unrelated hourly booking-metrics feed — no conflict.)
3. **MOD line items deferred.** `DL_INVOICE_ITEM_MODIFIERS` never landed and `DL_ORDER_ITEM_MODIFIERS` (empty) cannot be keyed to invoice items. MOD **hub** staging is included (from DL_MODIFIER_SETS/DL_MODIFIERS); MOD **lines** and the Tier 3 LINEITEM_LINEITEM step wait for data.
4. **Mews naming everywhere.** New folder `ClaudeDevelopment/integrations/Mews/`; staging tables `MEWS_*`; the Bizon folder is kept as design history.
5. **Product hierarchy: dual-layer with synthetic BOTTOM keys** (user's model) — see §3.
6. **Invoice remains the CUSTORDER source** joined to Order for operational metadata (April decision, unchanged).
7. **Single-tax assumption for LINEITEM_TAX** — see §4.3.

## 2a. Plan-phase amendments (2026-07-03, later same day)

Writing the implementation plan (`docs/superpowers/plans/2026-07-03-mews-dv-mapping.md`) against platform mechanics refined this spec:

1. **Link mappings source Tier-1 staging tables directly** (Growyze/NCRAloha precedent: both key columns `hash:1` in EntityMappings). The separate Tier-2 link staging layer in §4.3 is replaced by two small NULL-filtering steps (`MEWS_CUSTORDER_REVCENTER_LNK`, `MEWS_DISCOUNT_LINEITEM_LNK`) — `exclude_conditions` is unused platform-wide, so staging must guarantee non-null link keys. **Counts become 17 staging steps (15 Tier 1 + 2 Tier 2) and 25 mappings (15 hub + 10 link).**
2. **PRODUCT is ONE mapping row, not four** — the staging table carries all hierarchy levels and the platform maps per (entity, source_table), same as Growyze's 3-level INVITEM. Ditto MOD (1 row) and LINEITEM (3 rows — one per staging table, not per type).
3. **ADDRESS and CONTACT get their own staging steps** (`MEWS_ADDRESS`, `MEWS_CONTACT`) — a mapping cannot fan one customer row into two contact rows, and EntityMappings is keyed on (entity_name, source_table).
4. **Load steps are generated, not hand-written:** new deliverable `03_upload_load_steps.sql` runs `EXEC [core].[UploadEntityMappings] @intSchema = N'int_mews001'` to translate mappings into `step_type='Load'` StagingControl rows. This is the piece Growyze's dev scripts lacked (why its data never reached the DV).
5. **Further landed-schema deltas:** `DL_PAYMENT_METHODS` has only `id/name/active` and `active` is NULL on all rows (tolerant filter `COALESCE(active,'1') <> '0'`); `DL_TAXES` has `rate` (already a multiplier, `0.2`) not `ratePercent`, and no `isActive`; **variants carry no selector/sku/barcode** — display names synthesized as `{product name} @ {price}` (flag to fetcher team: the flattener is not capturing variant names).
6. Verification script renumbered to `04_verification.sql`; `DEPLOY.txt` added.

## 3. Product hierarchy

Same business key cannot sit at two hierarchy levels under one hub (LEVEL_NAME/BOTTOM_LEVEL are SAT attributes; SCD Type 2 keeps one current row per HUB_ID). So the bottom-layer copy of each product gets a **synthetic key**:

- **TOP:** product type (`DL_PRODUCT_TYPES.id`), PARENT_ID = NULL
- **MIDDLE_1:** product (`DL_PRODUCTS.id`), PARENT_ID = productTypeId
- **BOTTOM (BOTTOM_LEVEL=1):**
  - every variant (`DL_PRODUCT_VARIANTS.id`), PARENT_ID = productId, name = COALESCE(selector, sku, id)
  - **plus** one synthetic row per product: key `CONCAT(productId, '-DEFAULT')`, PARENT_ID = productId, name = product name
- **Line-item product key:** `COALESCE(productVariantId, CONCAT(productId, '-DEFAULT'))`

Why: verified against landed data, every sale line carries productId, and variantId only when a variant was chosen (invoice items: 3 variant-keyed, 18 product-only on variant-less products, 1 product-only on a variant-bearing product; order items identical). This resolution maps 100% of sale lines to a BOTTOM member, including the ambiguous case. Levels never flip when a product gains variants later, so no historic link re-orphans. Cost: ~98 synthetic BOTTOM members mirroring their parents' names. The `D_PRODUCT` recursive build (roots at `BOTTOM_LEVEL = 1`, walks PARENT_ID, COALESCEs missing middles) handles this shape unchanged.

## 4. Staging steps

All steps: idempotent `DROP TABLE IF EXISTS` + `SELECT INTO`, output `stage.MEWS_*`, dedup `ROW_NUMBER() OVER (PARTITION BY <key> ORDER BY LOADTS_UTC DESC) = 1`, `MICROSERVICE_NAME`/`MICROSERVICE_ID = NULL` (MDM layer — never populated by pipelines).

### 4.1 Tier 1 (13 steps)

| # | Table | Source | Key points |
|---|---|---|---|
| 1 | `MEWS_LOCATION` | DL_OUTLETS | BOTTOM only; LOCATION_NAME = name |
| 2 | `MEWS_PRODUCT` | DL_PRODUCT_TYPES ∪ DL_PRODUCTS ∪ DL_PRODUCT_VARIANTS ∪ synthetic | 4-part UNION per §3; filter `status != 'inactive' OR status IS NULL` on products |
| 3 | `MEWS_MOD` | DL_MODIFIER_SETS + DL_MODIFIERS | 2-level (sets=TOP, modifiers=BOTTOM); empty until data lands |
| 4 | `MEWS_TAX` | DL_TAXES | TAX_MULTIPLIER = CAST(ratePercent AS DECIMAL(18,6))/100; filter `isActive = '1'` |
| 5 | `MEWS_TENDER` | DL_PAYMENT_METHODS | Dimension only (no tender lines possible); filter `isActive = '1'`; verify column list at build time (differs from design) |
| 6 | `MEWS_DISCOUNT` | DL_PROMO_CODES | DISCOUNT_NAME = COALESCE(description, code); VALUE_TYPE = discountType |
| 7 | `MEWS_CHANNEL` | DL_AREAS | Hub only; filter `isActive = '1'` |
| 8 | `MEWS_REVCENTER` | DL_REVENUE_CENTERS | Empty until data lands; filter `isActive = '1'` |
| 9 | `MEWS_CUSTORDER` | DL_INVOICES ⋈ DL_ORDERS ⋈ DL_REGISTERS | See §4.2 |
| 10 | `MEWS_LINEITEM` | DL_INVOICE_ITEMS ⋈ DL_INVOICES ⋈ DL_REGISTERS | LINEITEM_TYPE='PROD'; see §4.2 |
| 11 | `MEWS_LINEITEM_TAX` | same chain | LINEITEM_TYPE='TAX'; filter `CAST(tax AS DECIMAL(18,2)) != 0`; GROSS_VALUE = tax |
| 12 | `MEWS_LINEITEM_DISCOUNT` | same chain | LINEITEM_TYPE='DISCOUNT'; filter discount/discountAmount non-zero; GROSS_VALUE = amount × −1; 0 rows today |
| 13 | `MEWS_CUSTOMER` | DL_CUSTOMERS | FORENAME = fullName, SURNAME = NULL; feeds INDIVIDUAL + ADDRESS (`{id}-HOME`) + CONTACT (`{id}-EMAIL`, `{id}-PHONE`) |

### 4.2 Transactional key/value mappings

**CUSTORDER (from Invoice ⋈ Order ⋈ Register):**
- `HEADER_ID = CONCAT_WS('-', reg.outletId, inv.id)`
- `GRAND_TOTAL = CAST(inv.total AS DECIMAL(18,2))`, `GROSS_SALES = CAST(inv.subtotal ...)`, `TAX_TOTAL = CAST(inv.tax ...)`, `DISCOUNT_GROSS = CAST(COALESCE(inv.discountAmount,'0') ...)`, `NET_SALES = subtotal − discountAmount`
- `GUEST_COUNT = CAST(ord.covers AS INT)`; `ORDER_STATUS = ord.state`
- `TRADING_DATE = CAST(inv.createdAt AS DATE)`; `OPEN_TIME = ord.createdAt`, `CLOSE_TIME = inv.createdAt` (CAST AS DATETIME2 — ISO 8601 strings parse safely)
- `PAYMENT_STATUS = CASE WHEN inv.cancelled = '1' THEN 'CANCELLED' ELSE 'PAID' END`; filter `COALESCE(inv.cancelled,'0') != '1'`
- Join: `DL_INVOICES inv LEFT JOIN DL_ORDERS ord ON inv.orderId = ord.id LEFT JOIN DL_REGISTERS reg ON inv.registerId = reg.id`

**LINEITEM PROD (from InvoiceItem ⋈ Invoice ⋈ Register):**
- `SRC_KEY = CONCAT_WS('-', reg.outletId, ii.invoiceId, ii.id, 'PROD')`; `HEADER_ID` matches CUSTORDER
- `GROSS_VALUE = CAST(ii.total ...)`, `TAX_VALUE = CAST(ii.tax ...)`, `NET_VALUE = CAST(ii.subtotal ...)`, `QUANTITY = CAST(ii.quantity AS DECIMAL(18,4))`
- `VOID_FLAG = CASE WHEN ii.isVoid = '1' OR ii.isComp = '1' THEN 1 ELSE 0 END` (comp rows land with zeroed totals)
- **`LINEITEM_TIMESTAMP = CAST(ii.createdAt AS DATETIME2)`** — must be populated; NULL LINEITEM_TIMESTAMP silently voids F_LINEITEM_15MIN (Growyze lesson)
- `PRODUCT_SRC_KEY = COALESCE(ii.productVariantId, CONCAT(ii.productId, '-DEFAULT'))`

### 4.3 Tier 2 link staging (8 steps)

| # | Staging table | Link entity | Note |
|---|---|---|---|
| 1 | `MEWS_CUSTORDER_LOCATION` | CUSTORDER_LOCATION | from MEWS_CUSTORDER |
| 2 | `MEWS_CUSTORDER_LINEITEM` | CUSTORDER_LINEITEM | UNION of all line-item staging tables |
| 3 | `MEWS_LINEITEM_PRODUCT` | LINEITEM_PRODUCT | key per §3 |
| 4 | `MEWS_LINEITEM_TAX_LNK` | LINEITEM_TAX | **single-tax assumption**: items carry a tax amount but no tax id; the org has exactly one active tax profile, so all TAX lines link to it. Verification script alerts if `DL_TAXES` ever holds >1 active row. |
| 5 | `MEWS_DISCOUNT_LINEITEM` | DISCOUNT_LINEITEM | via invoice promoCodeId; 0 rows today |
| 6 | `MEWS_CUSTORDER_REVCENTER` | CUSTORDER_REVCENTER | via invoice revenueCenterId; 0 rows today |
| 7 | `MEWS_ADDRESS_INDIVIDUAL` | ADDRESS_INDIVIDUAL | from MEWS_CUSTOMER |
| 8 | `MEWS_CONTACT_INDIVIDUAL` | CONTACT_INDIVIDUAL | from MEWS_CUSTOMER |

No Tier 3 steps in this phase.

## 5. Entity mappings (~28 rows: 20 hub + 8 link)

Hub rows: LOCATION (1), PRODUCT (4 — TOP / MIDDLE_1 / BOTTOM-variant / BOTTOM-default), MOD (2), TAX (1), TENDER (1), DISCOUNT (1), CHANNEL (1), REVCENTER (1), CUSTORDER (1), LINEITEM (3 — PROD/TAX/DISCOUNT), INDIVIDUAL (1), ADDRESS (1), CONTACT (2). Link rows: the 8 in §4.3. All target entities are existing Live entities.

**Deferred vs the April design (40 → 28):** BOOKING hub + BOOKING_CUSTORDER, LINEITEM types MOD/TENDER/SVC, SVCCHARGE hub, links CHANNEL_CUSTORDER, LINEITEM_MOD, LINEITEM_TENDER, LINEITEM_SVCCHARGE, LINEITEM_LINEITEM, CUSTORDER_REFUND.

## 6. Deliverables

`ClaudeDevelopment/integrations/Mews/`:

| Script | Content |
|---|---|
| `01_staging_control.sql` | MERGE upserts into `core.int_mews001.StagingControl` (21 steps: 13 Tier 1 + 8 Tier 2) |
| `02_entity_mappings.sql` | MERGE upserts into `core.int_mews001.EntityMappings` (~28 rows) |
| `03_verification.sql` | Read-only checks: stage/hub/sat/link row counts vs DL expectations, single-tax guard, orphan-line check, F_LINEITEM_15MIN presence after load |

Rules: unqualified two-part names (no client DB hardcoding); MERGE on natural keys (never bare INSERT); GUID `id` columns rely on `DEFAULT NEWID()`; `QUERY_STATUS.md` updated after testing.

## 7. Testing

1. Every staging query MCP-tested against org 19 via three-part naming from `core` before it enters the script.
2. Expected checkpoints: 19 CUSTORDER rows; 21 PROD lines with VOID_FLAG=0 + 1 comp with VOID_FLAG=1 (22 total); ~389 PRODUCT members (12 TOP + 98 MIDDLE_1 + 181 variants + 98 synthetic − inactive); 2 LOCATION; 364 INDIVIDUAL; all 22 PROD lines resolve a BOTTOM product member.
3. Developer deploys scripts and runs `sp_DataVaultLoad` for org 19; DEV MCP unavailable after 8pm.
4. `03_verification.sql` run post-load; results recorded in `QUERY_STATUS.md`.

## 8. Known gaps / follow-ups

| Gap | Trigger to revisit |
|---|---|
| TENDER line items | Fetcher lands DL_ORDER_PAYMENTS or DL_PAYMENTS |
| MOD line items + LINEITEM_LINEITEM | Modifier data lands with a keyable invoice-item path |
| BOOKING v2 + BOOKING_CUSTORDER entities | Mews bookings flow (DL_BOOKINGS rows / orders with bookingId) |
| CHANNEL_CUSTORDER link | Order→table linkage lands (tableId on orders) |
| SVCCHARGE / surcharge | Surcharge columns land on DL_ORDERS |
| Multi-tax orgs | >1 active row in DL_TAXES breaks the single-tax link assumption (verification guard) |
| F_PRODUCT_MARGIN_DAY NET_COST | Requires a paired inventory integration (April design gap, unchanged) |
| DimCustomer bridge | CRM dashboard design (April design gap, unchanged) |
