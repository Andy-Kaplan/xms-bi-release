# Demo Organisation Data Generator — Design Spec

**Date:** 2026-03-16
**Status:** APPROVED
**Author:** Andrew Kaplan + Claude

## 1. Overview

A Python data generator that produces CSV files containing synthetic Data Vault records for a fictional casual dining chain ("The Oak & Vine"). A companion BULK INSERT SQL script loads the CSVs into a pre-provisioned demo organisation database. The standard presentation build then populates dashboards.

**Purpose:** Provide a realistic, demo-ready organisation with curated data narratives that salespeople can use to showcase XMS BI to prospective clients.

### What we're building

- A Python project in `ClaudeDevelopment/demo-data/`
- Generates ~50 CSV files (one per DV table)
- A SQL loader script that BULK INSERTs in dependency order
- After loading, the existing `PresentationControl` pipeline runs — no custom presentation logic

### What we're NOT building

- No DL tables, staging, or load layer data — injection at DV level only
- No new stored procedures or platform changes
- No integration API connections for the demo org
- No survey data yet (future addition)

### Prerequisites

The demo org must be provisioned via standard SPs:
1. `EXEC core.AddOrganisation` — register "The Oak & Vine"
2. `EXEC core.sp_DeployObjects` — deploy SPs to client DB
3. `EXEC core.MapOrganisationToIntegration` — map to POS + Inventory integrations (creates DV table DDLs)
4. `EXEC core.DeployPresentationTables` — create presentation table structures

---

## 2. The Demo Business — "The Oak & Vine"

A fictional casual dining chain. 6 restaurants across 3 UK cities, 6 months of trading history.

### Locations

| # | Name | City | Profile |
|---|---|---|---|
| 1 | The Oak & Vine — Soho | London | Nightlife area, strong weekend cocktail sales |
| 2 | The Oak & Vine — Covent Garden | London | Tourist-heavy, steady all-week, high dessert attachment |
| 3 | The Oak & Vine — Deansgate | Manchester | Nightlife area, strong Fri/Sat, burger+beer crowd |
| 4 | The Oak & Vine — Northern Quarter | Manchester | Trendy, brunch-heavy, good starter upselling culture |
| 5 | The Oak & Vine — Old Town | Edinburgh | **Narrative: struggling location** — declining revenue, higher waste |
| 6 | The Oak & Vine — New Town | Edinburgh | Steady performer, tourist trade, baseline comparator |

### Menu — ~80 items across 8 categories

| Category | ~Items | Price Range | Examples |
|---|---|---|---|
| Starters | 10 | £5.50–9.50 | Soup of the Day, Prawn Cocktail, Halloumi Fries, Chicken Wings |
| Mains | 15 | £12.00–24.00 | 8oz Ribeye, Chicken Supreme, Fish & Chips, Mushroom Risotto (v) |
| Burgers | 8 | £10.00–16.00 | Classic Burger, Oak & Vine Burger, Pulled Pork, Plant Burger (vg) |
| Sides | 8 | £3.00–5.50 | Chips, Sweet Potato Fries, House Salad, Onion Rings |
| Desserts | 8 | £6.00–9.00 | Sticky Toffee Pudding, Chocolate Brownie, Affogato, Sorbet (vg) |
| Soft Drinks | 10 | £2.50–4.50 | Cola, Lemonade, Sparkling Water, Fresh OJ, Mocktails |
| Cocktails | 10 | £9.00–13.00 | Espresso Martini, Margarita, Old Fashioned, Aperol Spritz |
| Wine & Beer | 11 | £4.50–9.00 | House Red/White/Rosé, Prosecco, IPA, Lager, Stout |

### Inventory — ~120 ingredients

Mapped to menu items via recipes. Categories: Proteins, Produce, Dairy, Dry Goods, Beverages, Coffee/Tea.

### Suppliers — 6

| Supplier | Category | Narrative role |
|---|---|---|
| Highland Meats Ltd | Proteins | **Narrative: margin squeeze** — raises beef prices twice |
| Green Valley Produce | Fresh produce | Reliable |
| Dairy Direct | Dairy & eggs | Reliable |
| Pantry Wholesale | Dry goods & sauces | Bulk supplier |
| City Drinks Co | Spirits, wine, beer | Seasonal supplier |
| Bean & Brew | Coffee & tea | Specialty supplier |

### Staff — ~30

5 per location: 1 manager, 2 servers, 1 bartender, 1 kitchen.

### Date range

2025-10-01 to 2026-03-31 (6 months, autumn → spring).

---

## 3. Data Vault Tables to Populate

Based on UAT `core.core.DataVaultEntities` (75 live entities). Only the subset needed for POS + Inventory dashboards is populated.

### Table structure patterns

| Table type | Columns |
|---|---|
| **Hub** | `HUB_ID` (BINARY(32)), `SRC` (NVARCHAR(255)), `IS_DELETED` (BIT), `LOAD_TS` (DATETIME2) |
| **Satellite** | `HUB_ID`, `SRC`, `LOAD_TS`, `EFFECTIVEFROM`, `EFFECTIVETO`, `CURRENT_FLAG`, `IS_DELETED`, + entity attributes |
| **Binary link** | `LNK_ID` (BINARY(32)), `SRC`, `LOAD_TS`, `{ENT1}_HUB_ID`, `{ENT2}_HUB_ID`, `{ENT1}_AGG` (BIT), `{ENT2}_AGG` (BIT) |
| **Self-ref link** | `LNK_ID`, `SRC`, `LOAD_TS`, `PARENT_HUB_ID`, `CHILD_HUB_ID`, `PARENT_AGG`, `CHILD_AGG` |
| **Multi-way link** (3+ entities) | `LNK_ID`, `SRC`, `LOAD_TS`, `{ENT1}_HUB_ID`, `{ENT2}_HUB_ID`, `{ENT3}_HUB_ID`, ... — **no AGG columns** |
| **Link satellite** | `LNK_ID`, `SRC`, `LOAD_TS`, + link-specific attributes (no SCD2 columns) |

Hierarchy entities (PRODUCT, LOCATION, INVITEM, SUPPLIER, etc.) use `PARENT_ID` / `LEVEL_NAME` / `BOTTOM_LEVEL` / `ATTR_1-5` / `MICROSERVICE_ID` / `MICROSERVICE_NAME` / `MICROSERVICE_ID_BIN` pattern in their satellites.

### SRC column — critical constraint

The `SRC` column on all DV tables must contain a **registered integration schema name** (e.g. `int_ncraloha001`, `int_marketman001`), not a placeholder like `'DEMO'`. The PresentationControl build steps INNER JOIN `SRC` to `core.core.Integrations.SchemaName` filtered by `IntegrationType`. If SRC doesn't match, all rows are silently excluded from presentation tables.

**Convention for demo data:**
- POS entities (CUSTORDER, LINEITEM, PRODUCT, LOCATION, EMPLOYEE, etc.) → `SRC = '{POS integration schema}'`
- Inventory entities (INVITEM, STOCKEVENT, INVREPORT, SUPPLIER, etc.) → `SRC = '{INVENTORY integration schema}'`

The actual schema names depend on which integrations are mapped to the demo org during provisioning.

### Hub + Satellite pairs (14 entities, 28 tables)

| Entity | Hub rows | SRC type | Key SAT attributes for demo |
|---|---|---|---|
| LOCATION | 6 | POS | Hierarchy (location → city → chain), MICROSERVICE_NAME, ATTR_1-5 |
| PRODUCT | ~80 | POS | Hierarchy (item → subcategory → category), MICROSERVICE_NAME, ATTR_1-5 |
| INVITEM | ~120 | INVENTORY | Hierarchy (item → subcategory → category), UOM, MICROSERVICE_NAME, ATTR_1-5 |
| SUPPLIER | 6 | INVENTORY | Hierarchy, MICROSERVICE_NAME |
| EMPLOYEE | ~30 | POS | SURNAME, FIRST_NAME, ACTIVE_DATE (DECIMAL, not DATETIME), PAYTYPE |
| CUSTORDER | ~55K | POS | GRAND_TOTAL, NET_SALES, TAX_TOTAL, GROSS_SALES, GUEST_COUNT, ITEM_COUNT, ORDER_DATE, TRADING_DATE, OPEN_TIME, CLOSE_TIME, TABLE_NO, ORDER_STATUS, PAYMENT_STATUS, TENDERED_SALES, DISCOUNT_GROSS/NET/TAX + _SRC pairs |
| LINEITEM | ~150K | POS | HEADER_ID, LINEITEM_TYPE, GROSS_VALUE, TAX_VALUE, NET_VALUE, QUANTITY, QUANTITY_INV, LINEITEM_TIMESTAMP, ITEM_DATE, ORDER_DATE, TRADING_DATE, VOID_FLAG, LINE_ID, LINE_ORDER, SRC_KEY |
| OCCASION | ~6 | POS | Hierarchy (Dine-In, Takeaway, etc.) |
| TENDER | ~4 | POS | Hierarchy (Card, Cash, Online, Voucher) |
| TAX | ~2 | POS | TAX_MULTIPLIER, hierarchy |
| REVCENTER | ~6 | POS | Hierarchy (one per location). Note: BOTTOM_LEVEL is NVARCHAR(255), not BIGINT |
| STOCKEVENT | ~3K | INVENTORY | EVENT_TYPE, EVENT_BEHAVIOUR, EVENT_TS, UOM, UOM_QUANITY (sic — known platform typo, do not correct), PACK_DESC, PACK_QUANTITY |
| INVREPORT | ~1K | INVENTORY | REPORTING_DATE + extensive cost/variance columns (38 attributes total) |
| DISCOUNT | ~5 | POS | VALUE_TYPE, VALUE, IS_WASTE, hierarchy |

**Dropped from original design:** POSTX — not referenced by any PresentationControl step. Generating ~55K rows + links adds no dashboard value.

**Note on EMPLOYEE.ACTIVE_DATE:** The entity definition types this as `DECIMAL(38,10)`, not `DATETIME2`. Python must output numeric values.

**Note on LINEITEM.HEADER_ID:** Used by PresentationControl as `COUNT(DISTINCT HEADER_ID)` for order counts. Must be populated — set to the CUSTORDER HUB_ID hex string or a unique order identifier.

### Link tables (20)

**POS links:**

| Link | Connects | ~Rows |
|---|---|---|
| LNK_CUSTORDER_LOCATION | Order → Location | ~55K |
| LNK_CUSTORDER_EMPLOYEE | Order → Server | ~55K |
| LNK_CUSTORDER_LINEITEM | Order → Line items | ~150K |
| LNK_CUSTORDER_OCCASION | Order → Occasion | ~55K |
| LNK_CUSTORDER_REVCENTER | Order → Rev center | ~55K |
| LNK_LINEITEM_PRODUCT | Line item → Product | ~90K (PROD type) |
| LNK_LINEITEM_TAX | Line item → Tax rate | ~55K (TAX type) |
| LNK_LINEITEM_OCCASION | Line item → Occasion | ~150K |
| LNK_EMPLOYEE_LINEITEM | Employee → Line item | ~150K |
| LNK_DISCOUNT_LINEITEM | Discount → Line item | ~5K |
| LNK_LINEITEM_LINEITEM | Self-ref: parent ↔ child line item | ~20K | SAT_LNK: LABEL, VALUE, INFO |

**Inventory links:**

| Link | Connects | ~Rows | SAT_LNK? |
|---|---|---|---|
| LNK_INVITEM_STOCKEVENT | Ingredient → Stock event | ~3K | No |
| LNK_LOCATION_STOCKEVENT | Location → Stock event | ~3K | No |
| LNK_INVITEM_INVREPORT | Ingredient → Report | ~1K | No |
| LNK_INVREPORT_LOCATION | Report → Location | ~1K | No |
| LNK_INVITEM_INVITEM | Recipe: parent ↔ child | ~300 | Yes: UOM, UOM_VALUE |
| LNK_INVITEM_OCCASION_PRODUCT | Recipe: ingredient → occasion + product | ~500 | Yes: UOM, UOM_VALUE |
| LNK_LOCATION_OCCASION_PRODUCT | Location-specific product pricing | ~480 | Yes: NET_PRICE, NET_COST, PRODUCT_ID |
| LNK_INVITEM_LOCATION_OCCASION_PRODUCT | 4-way: ingredient → location → occasion → product | ~2K | Yes: UOM, UOM_VALUE |

**Dropped from original design:** LNK_CUSTORDER_POSTX and LNK_LINEITEM_TENDER — POSTX is unused by presentation, and TENDER_HUB_ID is commented out in the F_LINEITEM_15MIN build.

**AGG columns:** Binary and self-ref links have `{ENT}_AGG` bit columns (aggregation flags used by CDC). For demo data, set all AGG columns to `0`. Multi-way links (INVITEM_OCCASION_PRODUCT, LOCATION_OCCASION_PRODUCT, INVITEM_LOCATION_OCCASION_PRODUCT) have no AGG columns.

### Totals

~14 hubs + 14 satellites + 19 links + 5 link satellites = **~52 CSV files**, ~420K total rows.

---

## 4. Python Generator Design

### Project structure

```
ClaudeDevelopment/demo-data/
├── config.py                # All tuneable parameters
├── generate.py              # Main entry point
├── hash_utils.py            # SHA-256 hash key generation (replicates core.SHA256Hash())
├── csv_writer.py            # Common CSV output logic
├── generators/
│   ├── __init__.py
│   ├── reference_data.py    # Locations, products, invitems, suppliers, employees, occasions, tenders, tax, revcenters, discounts
│   ├── recipes.py           # INVITEM_INVITEM + INVITEM_OCCASION_PRODUCT links
│   ├── orders.py            # CUSTORDERs + LINEITEMs + all POS links
│   ├── inventory.py         # STOCKEVENTs + INVREPORTs + inventory links
│   └── narratives.py        # Overlay functions that skew distributions for curated stories
├── output/                  # Generated CSVs (gitignored)
└── load_demo_data.sql       # BULK INSERT script
```

### config.py

All tuneable parameters in one place:

- **Date range:** START_DATE (2025-10-01), END_DATE (2026-03-31)
- **Scale:** NUM_LOCATIONS (6), NUM_PRODUCTS (~80), NUM_INVITEMS (~120), NUM_SUPPLIERS (6), NUM_EMPLOYEES (~30), AVG_ORDERS_PER_DAY_PER_LOCATION (50), AVG_ITEMS_PER_ORDER (3.2)
- **Locations:** Name, city, character profile (nightlife/tourist/steady/struggling)
- **Product categories:** Name, count, price range per category
- **Narrative parameters:** Thresholds, trigger dates, multipliers for each curated story
- **Co-occurrence affinity matrix:** Product pair → affinity weight

### hash_utils.py

Replicates `core.SHA256Hash()` using Python's `hashlib.sha256()`.

**Critical: UTF-16LE encoding.** SQL Server's `HASHBYTES('SHA2_256', CAST(@input AS VARBINARY(MAX)))` on NVARCHAR input produces UTF-16LE bytes before hashing. Python must encode the input string as UTF-16LE (`string.encode('utf-16-le')`) before hashing — using UTF-8 will produce completely different hash values.

**Hash formula:** `SHA256(CONCAT_WS('|', business_key_value, integration_schema_name))` — the integration schema name (e.g. `int_ncraloha001`) is salted into the hash. The Python function must accept both the business key and the SRC schema name.

For CSV output, writes as 64-char hex strings.

### generators/reference_data.py

Generates all dimension/reference entities: LOCATION, PRODUCT, INVITEM, SUPPLIER, EMPLOYEE, OCCASION, TENDER, TAX, REVCENTER, DISCOUNT.

For hierarchy entities, generates three tiers per entity:
- **BOTTOM** rows: `BOTTOM_LEVEL = 1`, `PARENT_ID = <middle-tier business key string>`, `LEVEL_NAME = 'BOTTOM'`
- **MIDDLE** rows: `BOTTOM_LEVEL = 0`, `PARENT_ID = <top-tier business key string>`, `LEVEL_NAME = 'MIDDLE_1'`
- **TOP** rows: `BOTTOM_LEVEL = 0`, `PARENT_ID = NULL`, `LEVEL_NAME = 'TOP'`

**Important:** `PARENT_ID` is `NVARCHAR(255)` and stores the **business key** of the parent row (e.g. the PRODUCT_ID string of the middle-tier record), not the BINARY(32) hash. The PresentationControl hierarchy CTE joins on `p.PRODUCT_ID = h.PARENT_ID`.

`MICROSERVICE_NAME` carries the display name shown on dashboards. SRC values must match registered integration schema names (see §3 SRC constraint).

### generators/recipes.py

Generates `LNK_INVITEM_INVITEM` (self-ref: parent=product-as-invitem, child=ingredient) and `LNK_INVITEM_OCCASION_PRODUCT` (ternary: invitem → occasion → product).

Each product gets 2-5 ingredient links with realistic UOM/UOM_VALUE in link satellites (e.g. "8oz Ribeye" → 227g beef fillet, 15g butter, 5g salt, 50ml red wine jus).

### generators/orders.py

The largest generator. Produces CUSTORDER + LINEITEM + all POS link tables.

**Flow per simulated day:**
1. For each location, determine order count (base rate × day-of-week multiplier × narrative overlays)
2. For each order:
   - Pick time slot (weighted: lunch 12-14, dinner 18-21)
   - Pick employee (from location roster)
   - Pick occasion (Dine-In 80%, Takeaway 15%, Delivery 5%)
   - Generate PROD line items using product weights + co-occurrence affinities
   - Generate matching TAX line items
   - Generate LNK_LINEITEM_LINEITEM self-ref links for modifier relationships (e.g. "Extra Shot" → parent "Espresso Martini")
   - Optionally generate DISCOUNT line items (~8% of orders)
   - Populate HEADER_ID on all line items (shared per order — used by presentation for `COUNT(DISTINCT HEADER_ID)`)
   - Sum totals → CUSTORDER summary (GRAND_TOTAL, NET_SALES, etc.)
3. Write all rows + link rows

**Co-occurrence engine:** After first product selected, subsequent selections biased by affinity matrix from config. E.g., "Classic Burger" selected → "IPA" gets 70% boost.

### generators/inventory.py

Generates STOCKEVENT + INVREPORT + inventory links.

**STOCKEVENT types:**
- **COUNT** — weekly per location per invitem (baseline snapshots)
- **ORDER** — 2-3×/week per location (supplier deliveries)
- **SALE** — daily per invitem per location (derived from order line items × recipe quantities)
- **WASTE** — daily, small % (elevated for Edinburgh Old Town)
- **TRANSFER** — occasional between locations

**INVREPORT:** Weekly inventory count summaries per location with running cost/variance columns.

### generators/narratives.py

Provides modifier functions called by orders.py and inventory.py:

- `apply_struggling_location(location, date)` — reduces order count, increases waste, lowers avg transaction from Feb 2026 for Edinburgh Old Town
- `apply_margin_squeeze(product, date)` — inflated ingredient cost after Dec 2025 and Feb 2026 (generates additional SAT_LNK rows with updated UOM_VALUE)
- `apply_weekend_effect(location, day_of_week)` — 2.5× order multiplier + cocktail/burger bias on Fri/Sat for nightlife locations
- `apply_seasonal_shift(date)` — sine-wave weight modifier: hearty items UP in Oct-Dec, light items UP in Jan-Mar
- `apply_cooccurrence(selected_products)` — biases next product selection based on affinity matrix

### Dependencies

Python 3.10+ standard library only: `hashlib`, `csv`, `random`, `datetime`, `uuid`. No external packages.

---

## 5. CSV Output & BULK INSERT Loader

### CSV format

- **Encoding:** UTF-8 with BOM
- **Delimiter:** Pipe `|` (product names contain commas)
- **datetime2:** ISO 8601 `YYYY-MM-DDTHH:MM:SS.nnnnnnn`
- **NULL:** Empty field (adjacent delimiters)
- **bit:** `1` or `0`
- **decimal:** Plain numeric, no currency symbols
- **Header row:** Included, skipped via `FIRSTROW = 2`

File naming matches DV tables: `hub_location.csv`, `sat_location.csv`, `lnk_custorder_lineitem.csv`, `sat_lnk_invitem_invitem.csv`, etc.

### BINARY(32) column handling

Standard BULK INSERT cannot directly convert hex strings to BINARY(32). Two options:

**Option A (recommended): Staging table approach.** The loader script creates a temporary staging table with NVARCHAR columns for all hash-key fields, BULK INSERTs the CSV, then INSERTs into the real DV table with `CONVERT(BINARY(32), col, 2)` (style 2 = hex string without `0x` prefix). This is the most reliable approach and avoids format file complexity. Python writes hash keys as 64-char hex strings (no `0x` prefix).

**Option B: XML format file.** One `.fmt` file per table mapping hex string columns to `SQLBINARY`. More complex to maintain but avoids the staging step.

The loader script will implement Option A.

### load_demo_data.sql

Parameterised with two variables:
```sql
DECLARE @CsvPath NVARCHAR(500) = N'C:\path\to\output';
DECLARE @DatabaseName NVARCHAR(255) = N'20260316_XMS_{GUID}';
```

**Load order:**
1. **Phase 0 — GlobalParameters** (must exist before presentation build): INSERT `LINEITEM_START`, `LINEITEM_END`, `STOCKEVENT_START`, `STOCKEVENT_END` into `core.GlobalParameters` for the demo org's database, matching the generated date range (2025-10-01 to 2026-03-31). Without these, all fact table builds return zero rows.
2. **Phase 1 — Hubs** (no dependencies): All 14 HUB_ tables via staging table approach
3. **Phase 2 — Satellites** (depend on HUB_IDs): All 14 SAT_ tables
4. **Phase 3 — Links** (depend on HUB_IDs): All 20 LNK_ tables
5. **Phase 4 — Link satellites** (depend on LNK_IDs): 5 SAT_LNK_ tables

Each load wrapped in TRY/CATCH. Phase failure stops execution. All table references use dynamic SQL with database name prefix.

**Post-load steps (in order):**
```sql
-- 1. Populate the CALENDAR presentation table
EXEC [{demo_db}].[core].[sp_PopulateCalendar]

-- 2. Run the presentation build (22 PresentationControl steps)
EXEC [{demo_db}].[core].[sp_ProcessPresentation]
```

Note: The procedure is `sp_ProcessPresentation`, not `sp_BuildPresentation`. It runs inside the client database context (no `@DatabaseName` parameter).

**Regeneration:** Optional `--TRUNCATE` section at top of script (commented out by default) for re-loading after config changes.

---

## 6. Curated Narratives

### Narrative 1: The Struggling Location (Edinburgh Old Town)

**Trigger:** 1 Feb 2026 → 31 Mar 2026 (gradual decline)

| Metric | Before Feb 1 | After Feb 1 |
|---|---|---|
| Daily order count | ~50 | ~38 (−25%) |
| Avg items per order | 3.2 | 2.6 (starter/dessert attachment halved) |
| Discount rate | 8% | 15% |
| Waste rate | baseline | +40% |

**Dashboard visibility:** Sales trend lines (revenue drop), location comparison bars (underperformer), waste cards (high %), heatmap (thinning evening trade).

### Narrative 2: The Margin Squeeze (Highland Meats → Ribeye)

**Trigger dates:** 1 Dec 2025, 15 Feb 2026

3 SAT_LNK_INVITEM_INVITEM records for the beef fillet ingredient:
- Oct 1: base cost (e.g. £8.50/kg)
- Dec 1: +15% (£9.78/kg)
- Feb 15: +12% again (£10.95/kg)

Ribeye selling price stays constant — margin compression visible purely from cost increase.

**Dashboard visibility:** Product margin trend (ribeye declining), cost-by-supplier (Highland Meats rising), product profitability table (ribeye drops rank).

### Narrative 3: The Weekend Effect (Soho + Deansgate)

Fri/Sat modifiers for nightlife locations:
- Order count: 2.5× multiplier
- Cocktails: 4× selection weight
- Burgers: 2× selection weight
- Desserts: 0.5× weight
- Peak time shift: 19:00 → 21:00

**Dashboard visibility:** Heatmap hot spots, day-of-week bars, product mix pie charts (cocktail share), location comparison.

### Narrative 4: Seasonal Shift (Autumn → Spring)

Sine-wave weight modifier across 6 months:
- **Oct–Dec:** Hearty mains, hot desserts, red wine, stout weighted UP
- **Jan–Mar:** Salads, lighter mains, cold desserts, cocktails, rosé weighted UP

Gradual transition — smooth trend lines, not step changes.

**Dashboard visibility:** Product trends (seasonal crossover), category mix stacked bars, top/bottom rankings shift between Q4 and Q1.

### Narrative 5: Co-occurrence Patterns

Affinity matrix biases product selection within orders:

| First product | Boosted companions | Affinity |
|---|---|---|
| Any burger | IPA, Lager, Chips, Onion Rings | 0.6–0.7 |
| 8oz Ribeye | House Red, Side Salad, Chips | 0.6–0.7 |
| Any cocktail | Any dessert | 0.5 |
| Starter (any) | Main (any) | 0.8 |
| Soup of the Day | Bread roll (side) | 0.7 |

Northern Quarter gets boosted starter→main attachment (0.9 vs 0.8). 3-4 "lonely" products with no strong affinity (Sparkling Water, House Salad as main).

**Dashboard visibility:** Co-occurrence heatmap hot spots, location-level attachment comparisons, cold rows for lonely products.

---

## 7. End-to-End Workflow

### Generate

```bash
cd ClaudeDevelopment/demo-data
python generate.py
```

~30-60 seconds. Produces ~50 CSVs in `output/` (~50-80MB). Generates `output/summary.txt` with row counts and narrative checkpoints.

### Load

Set variables in `load_demo_data.sql`, execute in SSMS. ~2-5 minutes with TABLOCK.

### Build presentation

```sql
-- Populate calendar dimension first
EXEC [{demo_db}].[core].[sp_PopulateCalendar]

-- Run the 22 PresentationControl steps
EXEC [{demo_db}].[core].[sp_ProcessPresentation]
```

### Configure report database

Separate SQL script: BiConfig, VisualisationConfig, DashboardGrid/Item/Filter records for the demo org.

### Verify

Spot-check vis queries: sales overview KPI, product margins, location comparison, co-occurrence heatmap.

### Regeneration

1. Adjust `config.py`
2. Re-run `python generate.py`
3. Uncomment TRUNCATE section in loader, re-execute
4. Re-run presentation build

---

## 8. Future: Adding Survey Data

When ready:
1. Add `generators/surveys.py` — QUESTION, ANSWER, TOUCHPOINT hubs + sats + LNK_ANSWER_QUESTION_TOUCHPOINT
2. Add survey config to `config.py`
3. Map demo org to Survey integration
4. Add CSVs to BULK INSERT script
5. Survey PresentationControl steps + vis queries already exist — they pick up data automatically
