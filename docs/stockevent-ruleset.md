# STOCKEVENT Event Type Ruleset

This document defines the canonical event types for the `SAT_STOCKEVENT` entity. All integration staging queries that produce STOCKEVENT records **must** use one of these EVENT_TYPE values with the correct EVENT_BEHAVIOUR.

The STOCKEVENT entity tracks inventory movements at the grain of **one row per inventory item per location per day**. Staging queries must aggregate to this grain if the source data is at a different level.

## Event Types

### ORDER (behaviour: `+`)

A stock order represents inventory that has been ordered from a supplier. Orders increase expected stock levels.

**When to use:** The source data represents goods received at a location — typically from delivery notes, purchase invoices, or goods-received records. Use `ORDER` even when the source table is called "deliveries" or "invoices" — what matters is that the record confirms stock arriving at a location.

**Do NOT double-count:** If the integration has both purchase orders and delivery notes, use only the **delivery notes** (the trusted confirmation of receipt), not the purchase orders. Loading both would double-count inbound stock.

**Grain:** One row per inventory item per location per day.

### TRANSFER (behaviour: `+` and `-`)

A stock transfer represents inventory movement between locations. Because STOCKEVENT is at the grain of item per location per day, a single source transfer record **must produce two output rows**:
- One **negative** (`-`) row for the sending (FROM) location
- One **positive** (`+`) row for the receiving (TO) location

**When to use:** The source data represents inter-location stock movements. Look for FROM_LOCATION / TO_LOCATION or equivalent columns in the source data.

**Grain:** Source transfer records must be split into two rows — one per location involved. Both sending and receiving locations must be represented as separate STOCKEVENT records.

### SALE (behaviour: `-`)

A sale represents inventory consumed through a sales transaction. Sales reduce stock levels.

**When to use:** The source data represents sales depletion of inventory items. This is often derived by joining menu/product data with recipe/ingredient data to reach inventory item level — sales data in POS systems is typically at dish/product level, not ingredient level.

**Grain:** One row per inventory item per location per day. Sales data may need recipe explosion to convert dish-level sales into ingredient-level depletion.

### WASTE (behaviour: `-`)

A waste event represents inventory that has been discarded or written off. Waste reduces stock levels.

**When to use:** The source data represents stock write-offs, spoilage, or waste records. Check whether waste is captured in a dedicated DL table or combined with other event types in a transactions table.

**Grain:** One row per inventory item per location per day.

### PRODUCTION (behaviour: `+` and `-`)

A production event represents the manufacture of finished items from component ingredients. Production **must produce two categories of rows**:
- **Negative** (`-`) rows for ingredients consumed during production
- **Positive** (`+`) rows for finished items produced

**When to use:** The source data represents manufacturing or prep events where raw ingredients are transformed into finished products. These may be derivable from a single source table, but additional tables may be required to resolve item keys.

**Grain:** Source production data is often in a single table but may require joins to resolve inventory item keys. Developer must evaluate whether finished items and consumed ingredients are in the same or separate tables.

### COUNT (behaviour: `COUNT`)

A count event is a physical stock count that establishes a **baseline stock level**. It is **not a movement event** — it is a snapshot.

All subsequent +/- events apply their behaviour against the value of the most recent COUNT record, up until the next COUNT is recorded. COUNT is therefore a distinct and critical event type that anchors the stock position at a point in time.

**When to use:** The source data represents physical inventory counts or stock-takes. The behaviour value is the literal string `COUNT`, not `+` or `-`.

**Grain:** Count values must be at the grain of inventory item per location per day.

## Summary Table

| EVENT_TYPE | EVENT_BEHAVIOUR | Stock Effect | Multi-Row | Sort |
|---|---|---|---|---|
| `ORDER` | `+` | Increases stock | No | 1 |
| `TRANSFER` | `-` (from) and `+` (to) | Moves stock between locations | Yes (2 rows per transfer) | 2 |
| `SALE` | `-` | Decreases stock | No | 3 |
| `WASTE` | `-` | Decreases stock | No | 4 |
| `PRODUCTION` | `-` (ingredients) and `+` (finished) | Transforms stock | Yes (ingredient + finished rows) | 5 |
| `COUNT` | `COUNT` | Establishes baseline | No | 6 |

## Integration Compliance

| Integration | EVENT_TYPEs Used | Known Issues |
|---|---|---|
| MarketMan | ORDER, TRANSFER, WASTE, SALE, PRODUCTION | `INVOICE` in PRE_ORDEREVENT staging (should be `ORDER`); `STOCKCOUNT` in count staging (should be `COUNT`) |
| Growyze | ORDER, WASTE, SALE | `DELIVERY` used in GRYZ_DN_EVENTS (should be `ORDER`) — fix pending in 02_staging_tier1.sql |
