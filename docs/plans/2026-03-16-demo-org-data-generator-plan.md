# Demo Organisation Data Generator — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Python data generator that produces CSV files of synthetic Data Vault records for a demo restaurant chain, plus a SQL loader script to BULK INSERT them into a provisioned demo org.

**Architecture:** Python generators create ~52 CSV files covering 14 hub/sat pairs + 19 links + 5 link satellites. A SQL loader script stages CSVs into temp tables (to handle BINARY(32) hex conversion), then inserts into the real DV tables. After loading, the existing `sp_ProcessPresentation` pipeline builds the dashboard data.

**Tech Stack:** Python 3.10+ (stdlib only: hashlib, csv, random, datetime, uuid), SQL Server T-SQL (BULK INSERT + dynamic SQL)

**Spec:** `docs/plans/2026-03-16-demo-org-data-generator.md`

---

## File Map

| File | Responsibility |
|---|---|
| `ClaudeDevelopment/demo-data/config.py` | All business data + tuneable parameters |
| `ClaudeDevelopment/demo-data/hash_utils.py` | SHA-256 hash generation (UTF-16LE, matching SQL Server) |
| `ClaudeDevelopment/demo-data/csv_writer.py` | Pipe-delimited CSV output with correct type formatting |
| `ClaudeDevelopment/demo-data/generators/__init__.py` | Package init |
| `ClaudeDevelopment/demo-data/generators/narratives.py` | 5 narrative modifier functions |
| `ClaudeDevelopment/demo-data/generators/reference_data.py` | Dimension entities: LOCATION, PRODUCT, INVITEM, SUPPLIER, EMPLOYEE, OCCASION, TENDER, TAX, REVCENTER, DISCOUNT |
| `ClaudeDevelopment/demo-data/generators/recipes.py` | Recipe links: INVITEM_INVITEM, INVITEM_OCCASION_PRODUCT, LOCATION_OCCASION_PRODUCT, INVITEM_LOCATION_OCCASION_PRODUCT |
| `ClaudeDevelopment/demo-data/generators/orders.py` | CUSTORDER + LINEITEM + all POS links + co-occurrence engine |
| `ClaudeDevelopment/demo-data/generators/inventory.py` | STOCKEVENT + INVREPORT + inventory links |
| `ClaudeDevelopment/demo-data/generate.py` | Main entry point — orchestrates generators, writes CSVs, produces summary |
| `ClaudeDevelopment/demo-data/load_demo_data.sql` | BULK INSERT loader with staging tables + GlobalParameters + post-load steps |
| `ClaudeDevelopment/demo-data/tests/test_hash_utils.py` | Hash function tests |
| `ClaudeDevelopment/demo-data/tests/test_csv_writer.py` | CSV format tests |
| `ClaudeDevelopment/demo-data/tests/test_generators.py` | Generator output shape/consistency tests |

---

## Chunk 1: Foundation

### Task 1: Project Scaffolding

**Files:**
- Create: `ClaudeDevelopment/demo-data/config.py`
- Create: `ClaudeDevelopment/demo-data/generators/__init__.py`
- Create: `ClaudeDevelopment/demo-data/tests/__init__.py`

- [ ] **Step 1: Create directory structure**

```bash
cd "C:\threerocks_data\XMS BI\Release"
mkdir -p ClaudeDevelopment/demo-data/generators
mkdir -p ClaudeDevelopment/demo-data/tests
mkdir -p ClaudeDevelopment/demo-data/output
```

- [ ] **Step 2: Create generators/__init__.py**

Empty file — just marks it as a package.

- [ ] **Step 3: Create tests/__init__.py**

Empty file.

- [ ] **Step 4: Create config.py with all business data**

This is the largest config file. It contains ALL the demo business data: locations, products, ingredients, suppliers, employees, categories, pricing, narrative parameters, and co-occurrence affinities.

```python
"""
Demo data generator configuration.
All tuneable parameters for "The Oak & Vine" casual dining chain.
"""
from datetime import date, time

# ── Date range ──────────────────────────────────────────────
START_DATE = date(2025, 10, 1)
END_DATE = date(2026, 3, 31)

# ── Integration schema names (set after provisioning) ──────
# These MUST match the actual integration schemas mapped to the demo org.
# SRC column on all DV tables must be one of these — PresentationControl
# INNER JOINs on SRC to core.Integrations.SchemaName.
POS_SRC = "int_ncraloha001"
INVENTORY_SRC = "int_marketman001"

# ── Scale ───────────────────────────────────────────────────
AVG_ORDERS_PER_DAY_PER_LOCATION = 50
AVG_ITEMS_PER_ORDER = 3.2

# ── Locations ───────────────────────────────────────────────
LOCATIONS = [
    {"id": "LOC001", "name": "The Oak & Vine — Soho",
     "city": "London", "profile": "nightlife"},
    {"id": "LOC002", "name": "The Oak & Vine — Covent Garden",
     "city": "London", "profile": "tourist"},
    {"id": "LOC003", "name": "The Oak & Vine — Deansgate",
     "city": "Manchester", "profile": "nightlife"},
    {"id": "LOC004", "name": "The Oak & Vine — Northern Quarter",
     "city": "Manchester", "profile": "upsell"},
    {"id": "LOC005", "name": "The Oak & Vine — Old Town",
     "city": "Edinburgh", "profile": "struggling"},
    {"id": "LOC006", "name": "The Oak & Vine — New Town",
     "city": "Edinburgh", "profile": "steady"},
]

# Location hierarchy: location → city → chain
LOCATION_HIERARCHY = {
    "cities": [
        {"id": "CITY_LON", "name": "London"},
        {"id": "CITY_MAN", "name": "Manchester"},
        {"id": "CITY_EDI", "name": "Edinburgh"},
    ],
    "chain": {"id": "CHAIN_OV", "name": "The Oak & Vine"},
    "city_map": {
        "LOC001": "CITY_LON", "LOC002": "CITY_LON",
        "LOC003": "CITY_MAN", "LOC004": "CITY_MAN",
        "LOC005": "CITY_EDI", "LOC006": "CITY_EDI",
    },
}

# ── Product categories ──────────────────────────────────────
CATEGORIES = [
    {"id": "CAT_START", "name": "Starters"},
    {"id": "CAT_MAIN", "name": "Mains"},
    {"id": "CAT_BURG", "name": "Burgers"},
    {"id": "CAT_SIDE", "name": "Sides"},
    {"id": "CAT_DESS", "name": "Desserts"},
    {"id": "CAT_SOFT", "name": "Soft Drinks"},
    {"id": "CAT_COCK", "name": "Cocktails"},
    {"id": "CAT_WINE", "name": "Wine & Beer"},
]

# ── Products (80 items) ────────────────────────────────────
# Each product: id, name, category_id, price, dietary flags, seasonal tag
PRODUCTS = [
    # --- Starters (10) ---
    {"id": "PROD001", "name": "Soup of the Day", "cat": "CAT_START",
     "price": 6.50, "dietary": "", "season": "cold"},
    {"id": "PROD002", "name": "Prawn Cocktail", "cat": "CAT_START",
     "price": 8.50, "dietary": "", "season": None},
    {"id": "PROD003", "name": "Halloumi Fries", "cat": "CAT_START",
     "price": 7.50, "dietary": "v", "season": None},
    {"id": "PROD004", "name": "Chicken Wings", "cat": "CAT_START",
     "price": 8.00, "dietary": "", "season": None},
    {"id": "PROD005", "name": "Bruschetta", "cat": "CAT_START",
     "price": 7.00, "dietary": "v", "season": "warm"},
    {"id": "PROD006", "name": "Scotch Egg", "cat": "CAT_START",
     "price": 7.50, "dietary": "", "season": "cold"},
    {"id": "PROD007", "name": "Calamari", "cat": "CAT_START",
     "price": 8.50, "dietary": "", "season": None},
    {"id": "PROD008", "name": "Garlic Mushrooms", "cat": "CAT_START",
     "price": 6.50, "dietary": "v,vg", "season": None},
    {"id": "PROD009", "name": "Pâté & Toast", "cat": "CAT_START",
     "price": 7.50, "dietary": "", "season": "cold"},
    {"id": "PROD010", "name": "Caprese Salad", "cat": "CAT_START",
     "price": 7.00, "dietary": "v", "season": "warm"},
    # --- Mains (15) ---
    {"id": "PROD011", "name": "8oz Ribeye", "cat": "CAT_MAIN",
     "price": 24.00, "dietary": "", "season": "cold"},
    {"id": "PROD012", "name": "Chicken Supreme", "cat": "CAT_MAIN",
     "price": 16.50, "dietary": "", "season": None},
    {"id": "PROD013", "name": "Fish & Chips", "cat": "CAT_MAIN",
     "price": 14.50, "dietary": "", "season": None},
    {"id": "PROD014", "name": "Mushroom Risotto", "cat": "CAT_MAIN",
     "price": 13.50, "dietary": "v", "season": None},
    {"id": "PROD015", "name": "Lamb Shank", "cat": "CAT_MAIN",
     "price": 19.50, "dietary": "", "season": "cold"},
    {"id": "PROD016", "name": "Sea Bass Fillet", "cat": "CAT_MAIN",
     "price": 18.00, "dietary": "", "season": "warm"},
    {"id": "PROD017", "name": "Pork Belly", "cat": "CAT_MAIN",
     "price": 17.00, "dietary": "", "season": "cold"},
    {"id": "PROD018", "name": "Chicken Caesar Salad", "cat": "CAT_MAIN",
     "price": 13.00, "dietary": "", "season": "warm"},
    {"id": "PROD019", "name": "Steak & Ale Pie", "cat": "CAT_MAIN",
     "price": 15.00, "dietary": "", "season": "cold"},
    {"id": "PROD020", "name": "Grilled Salmon", "cat": "CAT_MAIN",
     "price": 17.50, "dietary": "", "season": "warm"},
    {"id": "PROD021", "name": "Veggie Tagine", "cat": "CAT_MAIN",
     "price": 13.00, "dietary": "v,vg", "season": None},
    {"id": "PROD022", "name": "Duck Breast", "cat": "CAT_MAIN",
     "price": 21.00, "dietary": "", "season": None},
    {"id": "PROD023", "name": "Prawn Linguine", "cat": "CAT_MAIN",
     "price": 15.50, "dietary": "", "season": "warm"},
    {"id": "PROD024", "name": "Beef Bourguignon", "cat": "CAT_MAIN",
     "price": 16.00, "dietary": "", "season": "cold"},
    {"id": "PROD025", "name": "Goat Cheese Tart", "cat": "CAT_MAIN",
     "price": 13.50, "dietary": "v", "season": "warm"},
    # --- Burgers (8) ---
    {"id": "PROD026", "name": "Classic Burger", "cat": "CAT_BURG",
     "price": 13.00, "dietary": "", "season": None},
    {"id": "PROD027", "name": "Oak & Vine Burger", "cat": "CAT_BURG",
     "price": 15.50, "dietary": "", "season": None},
    {"id": "PROD028", "name": "Pulled Pork Burger", "cat": "CAT_BURG",
     "price": 14.50, "dietary": "", "season": None},
    {"id": "PROD029", "name": "Plant Burger", "cat": "CAT_BURG",
     "price": 13.00, "dietary": "vg", "season": None},
    {"id": "PROD030", "name": "Chicken Burger", "cat": "CAT_BURG",
     "price": 13.50, "dietary": "", "season": None},
    {"id": "PROD031", "name": "Lamb Burger", "cat": "CAT_BURG",
     "price": 14.00, "dietary": "", "season": None},
    {"id": "PROD032", "name": "Fish Burger", "cat": "CAT_BURG",
     "price": 13.50, "dietary": "", "season": None},
    {"id": "PROD033", "name": "Halloumi Burger", "cat": "CAT_BURG",
     "price": 13.00, "dietary": "v", "season": None},
    # --- Sides (8) ---
    {"id": "PROD034", "name": "Chips", "cat": "CAT_SIDE",
     "price": 4.00, "dietary": "v,vg", "season": None},
    {"id": "PROD035", "name": "Sweet Potato Fries", "cat": "CAT_SIDE",
     "price": 4.50, "dietary": "v,vg", "season": None},
    {"id": "PROD036", "name": "House Salad", "cat": "CAT_SIDE",
     "price": 4.00, "dietary": "v,vg", "season": "warm"},
    {"id": "PROD037", "name": "Onion Rings", "cat": "CAT_SIDE",
     "price": 4.50, "dietary": "v", "season": None},
    {"id": "PROD038", "name": "Bread Roll", "cat": "CAT_SIDE",
     "price": 3.00, "dietary": "v", "season": None},
    {"id": "PROD039", "name": "Coleslaw", "cat": "CAT_SIDE",
     "price": 3.50, "dietary": "v", "season": None},
    {"id": "PROD040", "name": "Mac & Cheese", "cat": "CAT_SIDE",
     "price": 5.00, "dietary": "v", "season": "cold"},
    {"id": "PROD041", "name": "Seasonal Veg", "cat": "CAT_SIDE",
     "price": 4.50, "dietary": "v,vg", "season": None},
    # --- Desserts (8) ---
    {"id": "PROD042", "name": "Sticky Toffee Pudding", "cat": "CAT_DESS",
     "price": 7.50, "dietary": "v", "season": "cold"},
    {"id": "PROD043", "name": "Chocolate Brownie", "cat": "CAT_DESS",
     "price": 7.00, "dietary": "v", "season": None},
    {"id": "PROD044", "name": "Affogato", "cat": "CAT_DESS",
     "price": 6.50, "dietary": "v", "season": "warm"},
    {"id": "PROD045", "name": "Sorbet Trio", "cat": "CAT_DESS",
     "price": 6.00, "dietary": "v,vg", "season": "warm"},
    {"id": "PROD046", "name": "Crème Brûlée", "cat": "CAT_DESS",
     "price": 7.50, "dietary": "v", "season": None},
    {"id": "PROD047", "name": "Apple Crumble", "cat": "CAT_DESS",
     "price": 7.00, "dietary": "v", "season": "cold"},
    {"id": "PROD048", "name": "Cheese Board", "cat": "CAT_DESS",
     "price": 9.00, "dietary": "v", "season": None},
    {"id": "PROD049", "name": "Panna Cotta", "cat": "CAT_DESS",
     "price": 7.00, "dietary": "v", "season": "warm"},
    # --- Soft Drinks (10) ---
    {"id": "PROD050", "name": "Cola", "cat": "CAT_SOFT",
     "price": 3.00, "dietary": "v,vg", "season": None},
    {"id": "PROD051", "name": "Diet Cola", "cat": "CAT_SOFT",
     "price": 3.00, "dietary": "v,vg", "season": None},
    {"id": "PROD052", "name": "Lemonade", "cat": "CAT_SOFT",
     "price": 3.00, "dietary": "v,vg", "season": None},
    {"id": "PROD053", "name": "Sparkling Water", "cat": "CAT_SOFT",
     "price": 2.50, "dietary": "v,vg", "season": None},
    {"id": "PROD054", "name": "Still Water", "cat": "CAT_SOFT",
     "price": 2.50, "dietary": "v,vg", "season": None},
    {"id": "PROD055", "name": "Fresh Orange Juice", "cat": "CAT_SOFT",
     "price": 4.00, "dietary": "v,vg", "season": None},
    {"id": "PROD056", "name": "Apple Juice", "cat": "CAT_SOFT",
     "price": 3.50, "dietary": "v,vg", "season": None},
    {"id": "PROD057", "name": "Elderflower Pressé", "cat": "CAT_SOFT",
     "price": 4.00, "dietary": "v,vg", "season": "warm"},
    {"id": "PROD058", "name": "Ginger Beer", "cat": "CAT_SOFT",
     "price": 3.50, "dietary": "v,vg", "season": None},
    {"id": "PROD059", "name": "Virgin Mojito", "cat": "CAT_SOFT",
     "price": 4.50, "dietary": "v,vg", "season": "warm"},
    # --- Cocktails (10) ---
    {"id": "PROD060", "name": "Espresso Martini", "cat": "CAT_COCK",
     "price": 11.00, "dietary": "v", "season": None},
    {"id": "PROD061", "name": "Margarita", "cat": "CAT_COCK",
     "price": 10.50, "dietary": "v,vg", "season": "warm"},
    {"id": "PROD062", "name": "Old Fashioned", "cat": "CAT_COCK",
     "price": 11.50, "dietary": "v,vg", "season": "cold"},
    {"id": "PROD063", "name": "Aperol Spritz", "cat": "CAT_COCK",
     "price": 10.00, "dietary": "v,vg", "season": "warm"},
    {"id": "PROD064", "name": "Mojito", "cat": "CAT_COCK",
     "price": 10.50, "dietary": "v,vg", "season": "warm"},
    {"id": "PROD065", "name": "Negroni", "cat": "CAT_COCK",
     "price": 11.00, "dietary": "v,vg", "season": None},
    {"id": "PROD066", "name": "Pornstar Martini", "cat": "CAT_COCK",
     "price": 11.50, "dietary": "v", "season": None},
    {"id": "PROD067", "name": "Piña Colada", "cat": "CAT_COCK",
     "price": 10.50, "dietary": "v", "season": "warm"},
    {"id": "PROD068", "name": "Whisky Sour", "cat": "CAT_COCK",
     "price": 11.00, "dietary": "v,vg", "season": "cold"},
    {"id": "PROD069", "name": "Cosmopolitan", "cat": "CAT_COCK",
     "price": 10.50, "dietary": "v,vg", "season": None},
    # --- Wine & Beer (11) ---
    {"id": "PROD070", "name": "House Red", "cat": "CAT_WINE",
     "price": 6.50, "dietary": "v,vg", "season": "cold"},
    {"id": "PROD071", "name": "House White", "cat": "CAT_WINE",
     "price": 6.50, "dietary": "v,vg", "season": "warm"},
    {"id": "PROD072", "name": "House Rosé", "cat": "CAT_WINE",
     "price": 6.50, "dietary": "v,vg", "season": "warm"},
    {"id": "PROD073", "name": "Prosecco", "cat": "CAT_WINE",
     "price": 7.50, "dietary": "v,vg", "season": None},
    {"id": "PROD074", "name": "IPA", "cat": "CAT_WINE",
     "price": 5.50, "dietary": "v,vg", "season": None},
    {"id": "PROD075", "name": "Lager", "cat": "CAT_WINE",
     "price": 5.00, "dietary": "v,vg", "season": None},
    {"id": "PROD076", "name": "Stout", "cat": "CAT_WINE",
     "price": 5.50, "dietary": "v,vg", "season": "cold"},
    {"id": "PROD077", "name": "Pale Ale", "cat": "CAT_WINE",
     "price": 5.50, "dietary": "v,vg", "season": None},
    {"id": "PROD078", "name": "Cider", "cat": "CAT_WINE",
     "price": 5.00, "dietary": "v,vg", "season": "warm"},
    {"id": "PROD079", "name": "Sauvignon Blanc", "cat": "CAT_WINE",
     "price": 7.50, "dietary": "v,vg", "season": "warm"},
    {"id": "PROD080", "name": "Merlot", "cat": "CAT_WINE",
     "price": 7.00, "dietary": "v,vg", "season": "cold"},
]

# Product hierarchy: product → category → "Food" or "Drinks"
PRODUCT_SUPER_CATEGORIES = [
    {"id": "SCAT_FOOD", "name": "Food",
     "children": ["CAT_START", "CAT_MAIN", "CAT_BURG", "CAT_SIDE", "CAT_DESS"]},
    {"id": "SCAT_DRINK", "name": "Drinks",
     "children": ["CAT_SOFT", "CAT_COCK", "CAT_WINE"]},
]

# ── Suppliers (6) ───────────────────────────────────────────
SUPPLIERS = [
    {"id": "SUP001", "name": "Highland Meats Ltd", "category": "Proteins"},
    {"id": "SUP002", "name": "Green Valley Produce", "category": "Produce"},
    {"id": "SUP003", "name": "Dairy Direct", "category": "Dairy"},
    {"id": "SUP004", "name": "Pantry Wholesale", "category": "Dry Goods"},
    {"id": "SUP005", "name": "City Drinks Co", "category": "Beverages"},
    {"id": "SUP006", "name": "Bean & Brew", "category": "Coffee & Tea"},
]

# ── Occasions ───────────────────────────────────────────────
OCCASIONS = [
    {"id": "OCC001", "name": "Dine-In", "weight": 0.80},
    {"id": "OCC002", "name": "Takeaway", "weight": 0.12},
    {"id": "OCC003", "name": "Delivery", "weight": 0.05},
    {"id": "OCC004", "name": "Bar", "weight": 0.03},
]

# ── Tender types ────────────────────────────────────────────
TENDERS = [
    {"id": "TND001", "name": "Card", "weight": 0.70},
    {"id": "TND002", "name": "Cash", "weight": 0.15},
    {"id": "TND003", "name": "Online", "weight": 0.10},
    {"id": "TND004", "name": "Voucher", "weight": 0.05},
]

# ── Tax rates ───────────────────────────────────────────────
TAX_RATES = [
    {"id": "TAX001", "name": "VAT 20%", "multiplier": 0.20},
    {"id": "TAX002", "name": "Zero Rated", "multiplier": 0.00},
]

# ── Discount types ──────────────────────────────────────────
DISCOUNTS = [
    {"id": "DISC001", "name": "10% Off", "value_type": "PERCENT", "value": 10.0},
    {"id": "DISC002", "name": "20% Off", "value_type": "PERCENT", "value": 20.0},
    {"id": "DISC003", "name": "£5 Off", "value_type": "FIXED", "value": 5.0},
    {"id": "DISC004", "name": "Happy Hour", "value_type": "PERCENT", "value": 25.0},
    {"id": "DISC005", "name": "Staff Discount", "value_type": "PERCENT", "value": 50.0},
]

# ── Employees (30 = 5 per location) ────────────────────────
# Generated programmatically from name lists + location assignment
EMPLOYEE_NAMES = [
    # Soho (LOC001)
    ("James", "Mitchell", "Manager"), ("Sophie", "Clarke", "Server"),
    ("Ryan", "Patel", "Server"), ("Emma", "Williams", "Bartender"),
    ("Tom", "Baker", "Kitchen"),
    # Covent Garden (LOC002)
    ("Sarah", "Johnson", "Manager"), ("Alex", "Taylor", "Server"),
    ("Mia", "Brown", "Server"), ("Jake", "Wilson", "Bartender"),
    ("Liam", "Davies", "Kitchen"),
    # Deansgate (LOC003)
    ("Rachel", "Thompson", "Manager"), ("Ben", "Roberts", "Server"),
    ("Chloe", "Evans", "Server"), ("Dan", "Hughes", "Bartender"),
    ("Sam", "Green", "Kitchen"),
    # Northern Quarter (LOC004)
    ("Lucy", "Walker", "Manager"), ("Ollie", "Robinson", "Server"),
    ("Holly", "Wright", "Server"), ("Max", "Turner", "Bartender"),
    ("Ella", "Scott", "Kitchen"),
    # Old Town (LOC005)
    ("Fiona", "Campbell", "Manager"), ("Calum", "Stewart", "Server"),
    ("Isla", "Murray", "Server"), ("Ross", "Wallace", "Bartender"),
    ("Ewan", "MacDonald", "Kitchen"),
    # New Town (LOC006)
    ("Aimee", "Robertson", "Manager"), ("Gregor", "Anderson", "Server"),
    ("Niamh", "Fraser", "Server"), ("Angus", "Henderson", "Bartender"),
    ("Blair", "Mackie", "Kitchen"),
]

# ── Revenue Centers (1 per location) ───────────────────────
# Generated from LOCATIONS — one REVCENTER per location

# ── Narrative Configuration ─────────────────────────────────
NARRATIVES = {
    "struggling_location": {
        "location_id": "LOC005",
        "decline_start": date(2026, 2, 1),
        "order_decline_pct": 0.25,    # 25% fewer orders by end
        "items_per_order_target": 2.6, # down from 3.2
        "discount_rate": 0.15,         # up from 0.08
        "waste_multiplier": 1.40,      # 40% more waste
    },
    "margin_squeeze": {
        "supplier_id": "SUP001",       # Highland Meats
        "product_id": "PROD011",       # 8oz Ribeye
        "ingredient_id": "INV001",     # Beef Fillet (defined in recipes)
        "base_cost_per_kg": 8.50,
        "hike_1_date": date(2025, 12, 1),
        "hike_1_pct": 0.15,           # +15%
        "hike_2_date": date(2026, 2, 15),
        "hike_2_pct": 0.12,           # +12% on top
    },
    "weekend_effect": {
        "nightlife_locations": ["LOC001", "LOC003"],  # Soho, Deansgate
        "order_multiplier": 2.5,
        "cocktail_multiplier": 4.0,
        "burger_multiplier": 2.0,
        "dessert_multiplier": 0.5,
        "peak_shift_hours": 2,  # shift from 19:00 to 21:00
    },
    "seasonal_shift": {
        "cold_items": [p["id"] for p in PRODUCTS if p["season"] == "cold"],
        "warm_items": [p["id"] for p in PRODUCTS if p["season"] == "warm"],
        "peak_cold_month": 12,   # December
        "peak_warm_month": 3,    # March
        "max_weight_shift": 1.5, # max multiplier at peak
    },
    "cooccurrence": {
        "pairs": [
            # (trigger_category_or_id, boosted_ids, affinity)
            ("CAT_BURG", ["PROD074", "PROD075", "PROD034", "PROD037"], 0.65),
            ("PROD011", ["PROD070", "PROD036", "PROD034"], 0.65),  # Ribeye→Red wine+salad+chips
            ("CAT_COCK", ["CAT_DESS"], 0.50),  # Cocktails→Desserts
            ("CAT_START", ["CAT_MAIN"], 0.80),  # Starter→Main
            ("PROD001", ["PROD038"], 0.70),     # Soup→Bread roll
        ],
        "upsell_location": {
            "LOC004": {"CAT_START": 0.90},  # Northern Quarter: high starter attachment
        },
        "lonely_products": ["PROD053", "PROD054", "PROD036"],  # Sparkling Water, Still Water, House Salad (as main)
    },
}

# ── Base discount rate (for non-struggling locations) ───────
BASE_DISCOUNT_RATE = 0.08

# ── Time-of-day order distribution (hour → relative weight) ─
ORDER_TIME_WEIGHTS = {
    11: 0.5, 12: 1.5, 13: 1.5, 14: 1.0,
    15: 0.3, 16: 0.3, 17: 0.5,
    18: 1.2, 19: 1.8, 20: 1.8, 21: 1.2, 22: 0.5,
}

# ── Day-of-week base multipliers ───────────────────────────
DAY_OF_WEEK_MULTIPLIERS = {
    0: 0.8,  # Monday
    1: 0.85, # Tuesday
    2: 0.9,  # Wednesday
    3: 1.0,  # Thursday
    4: 1.3,  # Friday
    5: 1.4,  # Saturday
    6: 1.0,  # Sunday
}
```

- [ ] **Step 5: Verify config loads without errors**

Run: `cd ClaudeDevelopment/demo-data && python -c "import config; print(f'{len(config.PRODUCTS)} products, {len(config.LOCATIONS)} locations')"`
Expected: `80 products, 6 locations`

- [ ] **Step 6: Commit**

```bash
git add ClaudeDevelopment/demo-data/
git commit -m "feat(demo-data): project scaffolding + config with 80 products, 6 locations, 5 narratives"
```

---

### Task 2: Hash Utilities

**Files:**
- Create: `ClaudeDevelopment/demo-data/hash_utils.py`
- Create: `ClaudeDevelopment/demo-data/tests/test_hash_utils.py`

- [ ] **Step 1: Write the hash test**

The test verifies that Python produces the same hash as SQL Server's `core.SHA256Hash()`. We can verify by running `SELECT core.SHA256Hash(N'test|int_ncraloha001')` via MCP and comparing.

```python
"""Tests for hash_utils — verifies SHA-256 output matches SQL Server's core.SHA256Hash()."""
import pytest
from hash_utils import make_hub_id, make_lnk_id


def test_hub_id_is_32_bytes():
    result = make_hub_id("PROD001", "int_ncraloha001")
    assert isinstance(result, bytes)
    assert len(result) == 32


def test_hub_id_deterministic():
    a = make_hub_id("PROD001", "int_ncraloha001")
    b = make_hub_id("PROD001", "int_ncraloha001")
    assert a == b


def test_hub_id_different_keys():
    a = make_hub_id("PROD001", "int_ncraloha001")
    b = make_hub_id("PROD002", "int_ncraloha001")
    assert a != b


def test_hub_id_different_src():
    a = make_hub_id("PROD001", "int_ncraloha001")
    b = make_hub_id("PROD001", "int_marketman001")
    assert a != b


def test_hub_id_hex_roundtrip():
    """Hex string output can be converted back to bytes."""
    h = make_hub_id("PROD001", "int_ncraloha001")
    hex_str = h.hex()
    assert len(hex_str) == 64
    assert bytes.fromhex(hex_str) == h


def test_lnk_id_from_two_hubs():
    hub1 = make_hub_id("LI001", "int_ncraloha001")
    hub2 = make_hub_id("PROD001", "int_ncraloha001")
    lnk = make_lnk_id(hub1, hub2, src="int_ncraloha001")
    assert isinstance(lnk, bytes)
    assert len(lnk) == 32


def test_lnk_id_deterministic():
    hub1 = make_hub_id("LI001", "int_ncraloha001")
    hub2 = make_hub_id("PROD001", "int_ncraloha001")
    a = make_lnk_id(hub1, hub2, src="int_ncraloha001")
    b = make_lnk_id(hub1, hub2, src="int_ncraloha001")
    assert a == b


def test_utf16le_encoding():
    """Verify we use UTF-16LE encoding to match SQL Server's CAST(NVARCHAR AS VARBINARY)."""
    import hashlib
    input_str = "test|int_ncraloha001"
    expected = hashlib.sha256(input_str.encode("utf-16-le")).digest()
    result = make_hub_id("test", "int_ncraloha001")
    assert result == expected
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd ClaudeDevelopment/demo-data && python -m pytest tests/test_hash_utils.py -v`
Expected: FAIL — `ModuleNotFoundError: No module named 'hash_utils'`

- [ ] **Step 3: Implement hash_utils.py**

```python
"""
SHA-256 hash key generation matching SQL Server's core.SHA256Hash().

SQL Server computes: HASHBYTES('SHA2_256', CAST(@input AS VARBINARY(MAX)))
where @input is NVARCHAR(MAX). CAST(NVARCHAR → VARBINARY) produces UTF-16LE bytes.
Python must encode as UTF-16LE to produce identical hashes.

Hub hash formula: SHA256(CONCAT_WS('|', business_key, src_schema))
Link hash formula: SHA256(CONCAT_WS('|', hub_id_1_hex, hub_id_2_hex, ..., src_schema))
"""
import hashlib


def _sha256_sql(input_str: str) -> bytes:
    """Compute SHA-256 the same way SQL Server does on NVARCHAR input."""
    return hashlib.sha256(input_str.encode("utf-16-le")).digest()


def make_hub_id(business_key: str, src: str) -> bytes:
    """Generate a HUB_ID matching SQL Server's hash formula."""
    return _sha256_sql(f"{business_key}|{src}")


def make_lnk_id(*hub_ids: bytes, src: str) -> bytes:
    """Generate a LNK_ID from constituent hub IDs + src.

    Link hash = SHA256(hub1_hex|hub2_hex|...|src)
    """
    parts = [h.hex() for h in hub_ids]
    parts.append(src)
    return _sha256_sql("|".join(parts))


def to_hex(hash_bytes: bytes) -> str:
    """Convert BINARY(32) to 64-char hex string for CSV output."""
    return hash_bytes.hex().upper()
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd ClaudeDevelopment/demo-data && python -m pytest tests/test_hash_utils.py -v`
Expected: All 9 tests PASS

- [ ] **Step 5: Verify against SQL Server**

Run this MCP query, then compare with Python output:
```sql
SELECT CONVERT(VARCHAR(64), core.SHA256Hash(N'test|int_ncraloha001'), 2) AS hash_hex
```
Then in Python: `python -c "from hash_utils import make_hub_id, to_hex; print(to_hex(make_hub_id('test', 'int_ncraloha001')))"`

Both should produce the same 64-char hex string. If they don't match, the encoding is wrong.

- [ ] **Step 6: Commit**

```bash
git add ClaudeDevelopment/demo-data/hash_utils.py ClaudeDevelopment/demo-data/tests/test_hash_utils.py
git commit -m "feat(demo-data): hash_utils with UTF-16LE SHA-256 matching SQL Server"
```

---

### Task 3: CSV Writer

**Files:**
- Create: `ClaudeDevelopment/demo-data/csv_writer.py`
- Create: `ClaudeDevelopment/demo-data/tests/test_csv_writer.py`

- [ ] **Step 1: Write CSV writer tests**

```python
"""Tests for csv_writer — verifies pipe-delimited format, type handling, BOM."""
import os
import pytest
from csv_writer import DvCsvWriter
from datetime import datetime


def test_creates_file_with_bom(tmp_path):
    path = tmp_path / "test.csv"
    w = DvCsvWriter(str(path), ["COL_A", "COL_B"])
    w.close()
    raw = path.read_bytes()
    assert raw[:3] == b"\xef\xbb\xbf"  # UTF-8 BOM


def test_header_row(tmp_path):
    path = tmp_path / "test.csv"
    w = DvCsvWriter(str(path), ["HUB_ID", "SRC", "LOAD_TS"])
    w.close()
    lines = path.read_text(encoding="utf-8-sig").strip().split("\n")
    assert lines[0] == "HUB_ID|SRC|LOAD_TS"


def test_pipe_delimiter(tmp_path):
    path = tmp_path / "test.csv"
    w = DvCsvWriter(str(path), ["A", "B", "C"])
    w.writerow(["x", "y", "z"])
    w.close()
    lines = path.read_text(encoding="utf-8-sig").strip().split("\n")
    assert lines[1] == "x|y|z"


def test_none_as_empty(tmp_path):
    path = tmp_path / "test.csv"
    w = DvCsvWriter(str(path), ["A", "B"])
    w.writerow(["x", None])
    w.close()
    lines = path.read_text(encoding="utf-8-sig").strip().split("\n")
    assert lines[1] == "x|"


def test_binary_as_hex(tmp_path):
    path = tmp_path / "test.csv"
    w = DvCsvWriter(str(path), ["HUB_ID"])
    w.writerow([b"\x00" * 32])
    w.close()
    lines = path.read_text(encoding="utf-8-sig").strip().split("\n")
    assert lines[1] == "0" * 64


def test_datetime_format(tmp_path):
    path = tmp_path / "test.csv"
    w = DvCsvWriter(str(path), ["TS"])
    w.writerow([datetime(2025, 10, 1, 14, 30, 0)])
    w.close()
    lines = path.read_text(encoding="utf-8-sig").strip().split("\n")
    assert lines[1] == "2025-10-01T14:30:00.0000000"


def test_bool_as_bit(tmp_path):
    path = tmp_path / "test.csv"
    w = DvCsvWriter(str(path), ["FLAG"])
    w.writerow([True])
    w.writerow([False])
    w.close()
    lines = path.read_text(encoding="utf-8-sig").strip().split("\n")
    assert lines[1] == "1"
    assert lines[2] == "0"


def test_decimal_no_currency(tmp_path):
    path = tmp_path / "test.csv"
    w = DvCsvWriter(str(path), ["PRICE"])
    w.writerow([12.50])
    w.close()
    lines = path.read_text(encoding="utf-8-sig").strip().split("\n")
    assert lines[1] == "12.50"
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd ClaudeDevelopment/demo-data && python -m pytest tests/test_csv_writer.py -v`
Expected: FAIL

- [ ] **Step 3: Implement csv_writer.py**

```python
"""
Pipe-delimited CSV writer for Data Vault table CSVs.

Format conventions:
- UTF-8 with BOM (SQL Server BULK INSERT expects BOM)
- Pipe '|' delimiter (product names contain commas)
- BINARY(32): 64-char uppercase hex, no 0x prefix
- datetime2: ISO 8601 YYYY-MM-DDTHH:MM:SS.nnnnnnn
- NULL: empty string
- bit: 1 or 0
- decimal: plain numeric
"""
from datetime import datetime, date
from pathlib import Path


class DvCsvWriter:
    def __init__(self, filepath: str, columns: list[str]):
        self.filepath = filepath
        self.columns = columns
        Path(filepath).parent.mkdir(parents=True, exist_ok=True)
        self._f = open(filepath, "w", encoding="utf-8-sig", newline="")
        self._f.write("|".join(columns) + "\n")
        self._row_count = 0

    def writerow(self, values: list):
        parts = [self._format(v) for v in values]
        self._f.write("|".join(parts) + "\n")
        self._row_count += 1

    def close(self):
        self._f.close()

    @property
    def row_count(self):
        return self._row_count

    @staticmethod
    def _format(value) -> str:
        if value is None:
            return ""
        if isinstance(value, bytes):
            return value.hex().upper()
        if isinstance(value, bool):
            return "1" if value else "0"
        if isinstance(value, datetime):
            return value.strftime("%Y-%m-%dT%H:%M:%S.") + "0000000"
        if isinstance(value, date):
            return value.strftime("%Y-%m-%dT00:00:00.") + "0000000"
        if isinstance(value, float):
            if value == int(value) and abs(value) < 1e15:
                return f"{value:.2f}"
            return str(value)
        return str(value)

    def __enter__(self):
        return self

    def __exit__(self, *args):
        self.close()
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd ClaudeDevelopment/demo-data && python -m pytest tests/test_csv_writer.py -v`
Expected: All 8 tests PASS

- [ ] **Step 5: Commit**

```bash
git add ClaudeDevelopment/demo-data/csv_writer.py ClaudeDevelopment/demo-data/tests/test_csv_writer.py
git commit -m "feat(demo-data): CSV writer with pipe delimiter, hex BINARY, BOM encoding"
```

---

### Task 4: Narrative Modifiers

**Files:**
- Create: `ClaudeDevelopment/demo-data/generators/narratives.py`
- Create: `ClaudeDevelopment/demo-data/tests/test_narratives.py`

- [ ] **Step 1: Write narrative tests**

```python
"""Tests for narrative modifier functions."""
import pytest
from datetime import date
import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from generators.narratives import (
    get_order_count_multiplier,
    get_waste_multiplier,
    get_discount_rate,
    get_items_per_order,
    get_product_weight_multiplier,
    get_ingredient_cost_multiplier,
    get_time_shift_hours,
)
import config


def test_struggling_no_effect_before_trigger():
    mult = get_order_count_multiplier("LOC005", date(2026, 1, 15), day_of_week=2)
    # Before Feb 1 — no narrative effect beyond normal day-of-week
    assert mult == pytest.approx(config.DAY_OF_WEEK_MULTIPLIERS[2], rel=0.01)


def test_struggling_reduces_orders_after_trigger():
    mult = get_order_count_multiplier("LOC005", date(2026, 3, 31), day_of_week=2)
    base = config.DAY_OF_WEEK_MULTIPLIERS[2]
    assert mult < base  # should be reduced


def test_struggling_waste_elevated():
    mult = get_waste_multiplier("LOC005", date(2026, 3, 1))
    assert mult > 1.0


def test_normal_location_no_waste_boost():
    mult = get_waste_multiplier("LOC001", date(2026, 3, 1))
    assert mult == pytest.approx(1.0)


def test_weekend_nightlife_boost():
    # Friday (4) at Soho
    mult = get_order_count_multiplier("LOC001", date(2025, 10, 3), day_of_week=4)
    base_friday = config.DAY_OF_WEEK_MULTIPLIERS[4]
    assert mult > base_friday  # nightlife boost on top of Friday


def test_weekend_non_nightlife_normal():
    # Friday at Covent Garden (tourist, not nightlife)
    mult = get_order_count_multiplier("LOC002", date(2025, 10, 3), day_of_week=4)
    assert mult == pytest.approx(config.DAY_OF_WEEK_MULTIPLIERS[4], rel=0.01)


def test_seasonal_cold_item_boosted_in_december():
    mult = get_product_weight_multiplier("PROD011", date(2025, 12, 15))  # Ribeye (cold)
    assert mult > 1.0


def test_seasonal_warm_item_boosted_in_march():
    mult = get_product_weight_multiplier("PROD016", date(2026, 3, 15))  # Sea Bass (warm)
    assert mult > 1.0


def test_margin_squeeze_base_cost():
    mult = get_ingredient_cost_multiplier("INV001", date(2025, 11, 1))
    assert mult == pytest.approx(1.0)


def test_margin_squeeze_after_first_hike():
    mult = get_ingredient_cost_multiplier("INV001", date(2026, 1, 1))
    assert mult > 1.0  # 15% increase


def test_margin_squeeze_after_second_hike():
    mult = get_ingredient_cost_multiplier("INV001", date(2026, 3, 1))
    first = get_ingredient_cost_multiplier("INV001", date(2026, 1, 1))
    assert mult > first  # second hike on top


def test_nightlife_time_shift_on_weekend():
    shift = get_time_shift_hours("LOC001", day_of_week=5)  # Saturday at Soho
    assert shift > 0


def test_no_time_shift_on_weekday():
    shift = get_time_shift_hours("LOC001", day_of_week=2)  # Wednesday at Soho
    assert shift == 0
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd ClaudeDevelopment/demo-data && python -m pytest tests/test_narratives.py -v`
Expected: FAIL

- [ ] **Step 3: Implement narratives.py**

```python
"""
Narrative modifier functions.

These do NOT generate data — they return multipliers and modifiers that
orders.py, inventory.py, and recipes.py use to skew their distributions.
"""
import math
from datetime import date
import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
import config


def _days_into_decline(d: date) -> float:
    """Returns 0.0-1.0 progress through the struggling location's decline period."""
    cfg = config.NARRATIVES["struggling_location"]
    if d < cfg["decline_start"]:
        return 0.0
    total_days = (config.END_DATE - cfg["decline_start"]).days
    elapsed = (d - cfg["decline_start"]).days
    return min(elapsed / total_days, 1.0)


def _is_weekend(day_of_week: int) -> bool:
    return day_of_week in (4, 5)  # Friday, Saturday


def _is_nightlife(location_id: str) -> bool:
    return location_id in config.NARRATIVES["weekend_effect"]["nightlife_locations"]


def get_order_count_multiplier(location_id: str, d: date, day_of_week: int) -> float:
    """Combined order count multiplier from day-of-week + narratives."""
    base = config.DAY_OF_WEEK_MULTIPLIERS.get(day_of_week, 1.0)

    # Weekend nightlife boost
    if _is_weekend(day_of_week) and _is_nightlife(location_id):
        base *= config.NARRATIVES["weekend_effect"]["order_multiplier"]

    # Struggling location decline
    cfg = config.NARRATIVES["struggling_location"]
    if location_id == cfg["location_id"]:
        progress = _days_into_decline(d)
        base *= (1.0 - cfg["order_decline_pct"] * progress)

    return base


def get_items_per_order(location_id: str, d: date) -> float:
    """Average items per order, adjusted by struggling narrative."""
    base = config.AVG_ITEMS_PER_ORDER
    cfg = config.NARRATIVES["struggling_location"]
    if location_id == cfg["location_id"]:
        progress = _days_into_decline(d)
        target = cfg["items_per_order_target"]
        base = config.AVG_ITEMS_PER_ORDER - (config.AVG_ITEMS_PER_ORDER - target) * progress
    return base


def get_discount_rate(location_id: str, d: date) -> float:
    """Probability an order gets a discount."""
    cfg = config.NARRATIVES["struggling_location"]
    if location_id == cfg["location_id"]:
        progress = _days_into_decline(d)
        return config.BASE_DISCOUNT_RATE + (cfg["discount_rate"] - config.BASE_DISCOUNT_RATE) * progress
    return config.BASE_DISCOUNT_RATE


def get_waste_multiplier(location_id: str, d: date) -> float:
    """Waste rate multiplier (1.0 = normal)."""
    cfg = config.NARRATIVES["struggling_location"]
    if location_id == cfg["location_id"]:
        progress = _days_into_decline(d)
        return 1.0 + (cfg["waste_multiplier"] - 1.0) * progress
    return 1.0


def get_product_weight_multiplier(product_id: str, d: date) -> float:
    """Seasonal weight modifier for product selection."""
    cfg = config.NARRATIVES["seasonal_shift"]
    month = d.month
    # Sine wave: peaks at peak_cold_month for cold items, peak_warm_month for warm items
    if product_id in cfg["cold_items"]:
        peak = cfg["peak_cold_month"]
        angle = math.pi * 2 * (month - peak) / 12
        return 1.0 + (cfg["max_weight_shift"] - 1.0) * (1 + math.cos(angle)) / 2
    elif product_id in cfg["warm_items"]:
        peak = cfg["peak_warm_month"]
        angle = math.pi * 2 * (month - peak) / 12
        return 1.0 + (cfg["max_weight_shift"] - 1.0) * (1 + math.cos(angle)) / 2
    return 1.0


def get_cocktail_weight_multiplier(location_id: str, day_of_week: int) -> float:
    """Weekend cocktail boost for nightlife locations."""
    if _is_weekend(day_of_week) and _is_nightlife(location_id):
        return config.NARRATIVES["weekend_effect"]["cocktail_multiplier"]
    return 1.0


def get_burger_weight_multiplier(location_id: str, day_of_week: int) -> float:
    if _is_weekend(day_of_week) and _is_nightlife(location_id):
        return config.NARRATIVES["weekend_effect"]["burger_multiplier"]
    return 1.0


def get_dessert_weight_multiplier(location_id: str, day_of_week: int) -> float:
    if _is_weekend(day_of_week) and _is_nightlife(location_id):
        return config.NARRATIVES["weekend_effect"]["dessert_multiplier"]
    return 1.0


def get_ingredient_cost_multiplier(ingredient_id: str, d: date) -> float:
    """Margin squeeze — returns cost multiplier for beef ingredient."""
    cfg = config.NARRATIVES["margin_squeeze"]
    if ingredient_id != cfg["ingredient_id"]:
        return 1.0
    mult = 1.0
    if d >= cfg["hike_1_date"]:
        mult *= (1.0 + cfg["hike_1_pct"])
    if d >= cfg["hike_2_date"]:
        mult *= (1.0 + cfg["hike_2_pct"])
    return mult


def get_time_shift_hours(location_id: str, day_of_week: int) -> int:
    """Peak time shift (hours) for nightlife locations on weekends."""
    if _is_weekend(day_of_week) and _is_nightlife(location_id):
        return config.NARRATIVES["weekend_effect"]["peak_shift_hours"]
    return 0
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd ClaudeDevelopment/demo-data && python -m pytest tests/test_narratives.py -v`
Expected: All 14 tests PASS

- [ ] **Step 5: Commit**

```bash
git add ClaudeDevelopment/demo-data/generators/narratives.py ClaudeDevelopment/demo-data/tests/test_narratives.py
git commit -m "feat(demo-data): narrative modifiers — struggling location, margin squeeze, weekend, seasonal, cooccurrence"
```

---

## Chunk 2: Reference Data & Recipes

### Task 5: Reference Data Generator

**Files:**
- Create: `ClaudeDevelopment/demo-data/generators/reference_data.py`

This is the largest generator file. It produces hubs + sats for all 14 dimension entities, with correct three-tier hierarchy structure.

- [ ] **Step 1: Implement reference_data.py**

The generator must produce:
- **LOCATION**: 6 bottom + 3 middle (cities) + 1 top (chain) = 10 hub + 10 sat rows
- **PRODUCT**: 80 bottom + 8 middle (categories) + 2 top (Food/Drinks) = 90 hub + 90 sat rows
- **INVITEM**: ~120 bottom + ~6 middle (ingredient categories) + 1 top = ~127 hub + sat rows
- **SUPPLIER**: 6 bottom + 1 top (All Suppliers) = 7 hub + sat rows
- **EMPLOYEE**: 30 hub + 30 sat rows (no hierarchy)
- **OCCASION**: 4 bottom + 1 top = 5 hub + sat rows
- **TENDER**: 4 bottom + 1 top = 5 hub + sat rows
- **TAX**: 2 bottom + 1 top = 3 hub + sat rows
- **REVCENTER**: 6 bottom + 1 top = 7 hub + sat rows (BOTTOM_LEVEL is NVARCHAR(255))
- **DISCOUNT**: 5 bottom + 1 top = 6 hub + sat rows

Key implementation details:
- Every hub row: `HUB_ID` (from hash_utils), `SRC` (POS_SRC or INVENTORY_SRC), `IS_DELETED` = 0, `LOAD_TS` = START_DATE
- Every sat row: `HUB_ID`, `SRC`, `LOAD_TS` = START_DATE, `EFFECTIVEFROM` = START_DATE, `EFFECTIVETO` = None, `CURRENT_FLAG` = 1, `IS_DELETED` = 0, + entity-specific attributes
- Hierarchy sat rows: `PARENT_ID` = **business key string** of parent (not hash), `LEVEL_NAME`, `BOTTOM_LEVEL`
- `MICROSERVICE_NAME` = display name for all hierarchy entities
- EMPLOYEE `ACTIVE_DATE` is DECIMAL (e.g. `20251001.0000000000`)
- REVCENTER `BOTTOM_LEVEL` is NVARCHAR(255), not BIGINT
- STOCKEVENT column is `UOM_QUANITY` — this is a **known platform typo**. Do NOT correct it to `UOM_QUANTITY` — the staging table and DV table column is literally `UOM_QUANITY` and the names must match exactly.
- AGG columns on binary and self-ref links: always output `0`. Multi-way links have no AGG columns at all.

The function returns a `ReferenceData` dataclass containing all generated hub IDs indexed by business key, so downstream generators can look up HUB_IDs.

```python
"""
Generate all reference/dimension entities.

Outputs CSV files for 14 hub+sat pairs. Returns a ReferenceData object
with HUB_ID lookups for all entities, used by downstream generators.
"""
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path
import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
import config
from hash_utils import make_hub_id, to_hex
from csv_writer import DvCsvWriter


@dataclass
class ReferenceData:
    """Lookup tables of business_key → HUB_ID (bytes) for all reference entities."""
    locations: dict = field(default_factory=dict)      # loc_id → hub_id
    products: dict = field(default_factory=dict)        # prod_id → hub_id
    invitems: dict = field(default_factory=dict)        # invitem_id → hub_id
    suppliers: dict = field(default_factory=dict)       # sup_id → hub_id
    employees: dict = field(default_factory=dict)       # emp_id → hub_id
    occasions: dict = field(default_factory=dict)       # occ_id → hub_id
    tenders: dict = field(default_factory=dict)         # tnd_id → hub_id
    taxes: dict = field(default_factory=dict)           # tax_id → hub_id
    revcenters: dict = field(default_factory=dict)      # rc_id → hub_id
    discounts: dict = field(default_factory=dict)       # disc_id → hub_id
    # Employee → location mapping for order generation
    location_employees: dict = field(default_factory=dict)  # loc_id → [emp_ids]
    # Product → category mapping
    product_categories: dict = field(default_factory=dict)  # prod_id → cat_id
```

The full implementation writes hub + sat CSVs for each entity using `DvCsvWriter`. Hub columns are always `[HUB_ID, SRC, IS_DELETED, LOAD_TS]`. Sat columns vary per entity.

For hierarchy entities, the pattern is:
1. Create TOP tier row (PARENT_ID=None, LEVEL_NAME='TOP', BOTTOM_LEVEL=0)
2. Create MIDDLE tier rows (PARENT_ID=top's business key, LEVEL_NAME='MIDDLE_1', BOTTOM_LEVEL=0)
3. Create BOTTOM tier rows (PARENT_ID=middle's business key, LEVEL_NAME='BOTTOM', BOTTOM_LEVEL=1)

Each tier gets its own HUB_ID hash using its business key + SRC.

**Implementation note:** The full product list, ingredient definitions, and all attribute values are drawn from `config.py`. The generator iterates config data structures and writes rows — no random generation needed for reference data.

- [ ] **Step 2: Test reference data generation**

```bash
cd ClaudeDevelopment/demo-data
python -c "
from generators.reference_data import generate_reference_data
ref = generate_reference_data('output')
print(f'Locations: {len(ref.locations)}')
print(f'Products: {len(ref.products)}')
print(f'Employees: {len(ref.employees)}')
print(f'Occasions: {len(ref.occasions)}')
"
```

Expected output:
```
Locations: 10
Products: 90
Employees: 30
Occasions: 5
```

- [ ] **Step 3: Verify CSV format**

```bash
head -3 ClaudeDevelopment/demo-data/output/hub_product.csv
head -3 ClaudeDevelopment/demo-data/output/sat_product.csv
```

Verify: pipe-delimited, hex HUB_IDs (64 chars), correct column names, PARENT_ID is a business key string (not hex hash).

- [ ] **Step 4: Commit**

```bash
git add ClaudeDevelopment/demo-data/generators/reference_data.py
git commit -m "feat(demo-data): reference data generator — 14 entities with hierarchy tiers"
```

---

### Task 6: Recipe Generator

**Files:**
- Create: `ClaudeDevelopment/demo-data/generators/recipes.py`

Generates the recipe relationship links:
- `LNK_INVITEM_INVITEM` + `SAT_LNK_INVITEM_INVITEM` — self-ref: product-as-invitem → ingredient
- `LNK_INVITEM_OCCASION_PRODUCT` + `SAT_LNK_INVITEM_OCCASION_PRODUCT` — ternary
- `LNK_LOCATION_OCCASION_PRODUCT` + `SAT_LNK_LOCATION_OCCASION_PRODUCT` — location pricing
- `LNK_INVITEM_LOCATION_OCCASION_PRODUCT` + `SAT_LNK_INVITEM_LOCATION_OCCASION_PRODUCT` — 4-way

- [ ] **Step 1: Define recipe data in config.py**

Add a `RECIPES` dict to config.py mapping each product to its ingredients with UOM/quantity. Also add `INVITEMS` list with all ~120 ingredients.

This is a substantial config addition (~200 lines): each of the 80 products needs 2-5 ingredients with realistic quantities and UOMs (grams, ml, units).

- [ ] **Step 2: Implement recipes.py**

Key points:
- Self-ref link `LNK_INVITEM_INVITEM` uses `PARENT_HUB_ID` (product-as-invitem) and `CHILD_HUB_ID` (ingredient)
- `SAT_LNK_INVITEM_INVITEM` has `UOM` and `UOM_VALUE` columns — the quantity of each ingredient per recipe serving
- For the margin squeeze narrative: beef fillet ingredient gets **3 SAT_LNK rows** with different LOAD_TS dates showing cost increase over time
- Multi-way links have no AGG columns
- `LNK_LOCATION_OCCASION_PRODUCT` carries NET_PRICE and NET_COST per location — allows location-specific pricing

Returns a `RecipeData` dataclass with product→ingredient mappings for use by `orders.py` (to compute SALE stock events from line items × recipe quantities).

- [ ] **Step 3: Test recipe generation**

```bash
cd ClaudeDevelopment/demo-data
python -c "
from generators.reference_data import generate_reference_data
from generators.recipes import generate_recipes
ref = generate_reference_data('output')
recipes = generate_recipes('output', ref)
print(f'Recipe links: {len(recipes.product_ingredients)}')
"
```

Verify LNK_INVITEM_INVITEM CSV has ~300 rows, SAT_LNK has >300 (extra rows for margin squeeze SCD2).

- [ ] **Step 4: Commit**

```bash
git add ClaudeDevelopment/demo-data/generators/recipes.py ClaudeDevelopment/demo-data/config.py
git commit -m "feat(demo-data): recipe generator — INVITEM_INVITEM links + margin squeeze SCD2"
```

---

## Chunk 3: Transaction & Inventory Data

### Task 7: Order Generator

**Files:**
- Create: `ClaudeDevelopment/demo-data/generators/orders.py`

The largest and most complex generator. Produces ~55K CUSTORDERs + ~150K LINEITEMs + all POS link tables.

- [ ] **Step 1: Implement orders.py**

Core loop structure:
```python
for each day in date_range:
    for each location:
        order_count = base_count * get_order_count_multiplier(loc, day, dow)
        for i in range(order_count):
            order = generate_single_order(loc, day, ref, recipes)
            write_custorder(order)
            write_lineitems(order)
            write_all_links(order)
```

Each `generate_single_order` call:
1. Picks time slot using `ORDER_TIME_WEIGHTS` + `get_time_shift_hours()` narrative
2. Picks employee from `ref.location_employees[loc_id]`
3. Picks occasion using `OCCASIONS` weights
4. Determines item count from `get_items_per_order()` + random variance
5. Selects products using weighted random:
   - Base weight = 1.0 for all products
   - Category multipliers (cocktail boost, burger boost, dessert reduction) from narratives
   - Seasonal multiplier from `get_product_weight_multiplier()`
   - Co-occurrence affinity boost from config after first item selected
   - "Lonely" products get reduced companion affinity
6. For each PROD line item, generates a TAX line item (20% VAT for food, sometimes 0% for cold takeaway drinks)
7. Optionally generates DISCOUNT line items based on `get_discount_rate()`
8. Computes CUSTORDER totals (GRAND_TOTAL, NET_SALES, TAX_TOTAL, etc.)
9. All line items share a HEADER_ID (for `COUNT(DISTINCT HEADER_ID)` in presentation)

**LINEITEM types generated:**
- `PROD` — product sold (~90K rows, linked to product via LNK_LINEITEM_PRODUCT)
- `TAX` — tax on each PROD item (~55K rows, linked via LNK_LINEITEM_TAX)
- `DISCOUNT` — discount applied (~5K rows, linked via LNK_DISCOUNT_LINEITEM)

**Links generated per order:**
- LNK_CUSTORDER_LOCATION (1 per order)
- LNK_CUSTORDER_EMPLOYEE (1 per order)
- LNK_CUSTORDER_OCCASION (1 per order)
- LNK_CUSTORDER_REVCENTER (1 per order)
- LNK_CUSTORDER_LINEITEM (1 per line item)
- LNK_LINEITEM_PRODUCT (1 per PROD line item)
- LNK_LINEITEM_TAX (1 per TAX line item)
- LNK_LINEITEM_OCCASION (1 per line item)
- LNK_EMPLOYEE_LINEITEM (1 per line item)
- LNK_DISCOUNT_LINEITEM (1 per DISCOUNT line item)
- LNK_LINEITEM_LINEITEM (self-ref for modifier relationships, ~20K rows)

Returns daily sales summary per product per location for `inventory.py` to compute SALE stock events.

- [ ] **Step 2: Test order generation with small date range**

Temporarily set `START_DATE = date(2025, 10, 1)`, `END_DATE = date(2025, 10, 7)` in config (1 week) and run:

```bash
cd ClaudeDevelopment/demo-data
python -c "
from generators.reference_data import generate_reference_data
from generators.recipes import generate_recipes
from generators.orders import generate_orders
ref = generate_reference_data('output')
recipes = generate_recipes('output', ref)
sales = generate_orders('output', ref, recipes)
print(f'Days with sales: {len(sales)}')
"
```

Verify hub_custorder.csv and hub_lineitem.csv exist with reasonable row counts (~350 orders, ~1100 line items for 1 week).

- [ ] **Step 3: Spot-check CSV data quality**

Check that:
- LINEITEM_TYPE values are only PROD/TAX/DISCOUNT
- GROSS_VALUE > 0 for PROD items
- HEADER_ID is consistent across all line items in the same order
- ORDER_DATE matches TRADING_DATE
- All HUB_IDs are 64-char hex strings

- [ ] **Step 4: Commit**

```bash
git add ClaudeDevelopment/demo-data/generators/orders.py
git commit -m "feat(demo-data): order generator — CUSTORDER + LINEITEM + POS links + co-occurrence"
```

---

### Task 8: Inventory Generator

**Files:**
- Create: `ClaudeDevelopment/demo-data/generators/inventory.py`

Generates STOCKEVENT + INVREPORT + inventory links.

- [ ] **Step 1: Implement inventory.py**

STOCKEVENT generation:
- **SALE** events: derived from `sales_data` returned by `orders.py`. For each day/location/product, multiply line item quantities by recipe ingredient quantities to get ingredient consumption. One STOCKEVENT per ingredient per location per day. EVENT_BEHAVIOUR = '-'.
- **COUNT** events: weekly per location per ingredient. Running stock level = opening stock - sales - waste + orders + transfers. EVENT_BEHAVIOUR = 'COUNT'.
- **ORDER** events: 2-3× per week per location. Replenish ingredients that dropped below reorder point. EVENT_BEHAVIOUR = '+'.
- **WASTE** events: daily per location, small random percentage of stock. Elevated for Edinburgh Old Town via `get_waste_multiplier()`. EVENT_BEHAVIOUR = '-'.
- **TRANSFER** events: occasional between locations (e.g. 2-3 per week across the chain). EVENT_BEHAVIOUR = '+' for receiving location, '-' for sending.

INVREPORT generation:
- Weekly per location, summarising that week's stock position
- Columns: extensive (38 attributes including running totals, variance, cost)
- Most columns can be derived from STOCKEVENT aggregates

Links:
- LNK_INVITEM_STOCKEVENT (1 per STOCKEVENT)
- LNK_LOCATION_STOCKEVENT (1 per STOCKEVENT)
- LNK_INVITEM_INVREPORT (1 per ingredient per weekly report)
- LNK_INVREPORT_LOCATION (1 per weekly report)

- [ ] **Step 2: Test inventory generation**

```bash
cd ClaudeDevelopment/demo-data
python -c "
from generators.reference_data import generate_reference_data
from generators.recipes import generate_recipes
from generators.orders import generate_orders
from generators.inventory import generate_inventory
ref = generate_reference_data('output')
recipes = generate_recipes('output', ref)
sales = generate_orders('output', ref, recipes)
generate_inventory('output', ref, recipes, sales)
"
```

Verify: hub_stockevent.csv exists with ~3K rows, sat_stockevent.csv has EVENT_TYPE values from {SALE, COUNT, ORDER, WASTE, TRANSFER}.

- [ ] **Step 3: Commit**

```bash
git add ClaudeDevelopment/demo-data/generators/inventory.py
git commit -m "feat(demo-data): inventory generator — STOCKEVENT + INVREPORT + links"
```

---

## Chunk 4: Orchestration & Loader

### Task 9: Main Orchestrator

**Files:**
- Create: `ClaudeDevelopment/demo-data/generate.py`

- [ ] **Step 1: Implement generate.py**

```python
"""
Main entry point for demo data generation.

Usage: python generate.py [--output-dir OUTPUT_DIR]

Generates ~52 CSV files in the output directory, ready for BULK INSERT.
"""
import argparse
import time
from pathlib import Path

import config
from generators.reference_data import generate_reference_data
from generators.recipes import generate_recipes
from generators.orders import generate_orders
from generators.inventory import generate_inventory


def main():
    parser = argparse.ArgumentParser(description="Generate demo data for The Oak & Vine")
    parser.add_argument("--output-dir", default="output", help="Output directory for CSVs")
    args = parser.parse_args()

    output_dir = args.output_dir
    Path(output_dir).mkdir(parents=True, exist_ok=True)

    start = time.time()
    print(f"Generating demo data: {config.START_DATE} to {config.END_DATE}")
    print(f"  {len(config.LOCATIONS)} locations, {len(config.PRODUCTS)} products")
    print()

    # Phase 1: Reference data
    print("[1/4] Reference data (locations, products, employees, etc.)...")
    ref = generate_reference_data(output_dir)
    print(f"       {len(ref.products)} products, {len(ref.locations)} locations, "
          f"{len(ref.employees)} employees")

    # Phase 2: Recipes
    print("[2/4] Recipes (ingredient → product mappings)...")
    recipes = generate_recipes(output_dir, ref)
    print(f"       {len(recipes.product_ingredients)} recipe links")

    # Phase 3: Orders
    print("[3/4] Orders (this is the big one)...")
    sales = generate_orders(output_dir, ref, recipes)
    print(f"       Orders generated across {len(sales)} trading days")

    # Phase 4: Inventory
    print("[4/4] Inventory (stock events, reports)...")
    generate_inventory(output_dir, ref, recipes, sales)

    elapsed = time.time() - start
    print(f"\nDone in {elapsed:.1f}s. CSVs written to {output_dir}/")

    # Write summary
    write_summary(output_dir, ref, recipes, sales, elapsed)


def write_summary(output_dir, ref, recipes, sales, elapsed):
    """Write output/summary.txt with row counts and narrative checkpoints."""
    summary_path = Path(output_dir) / "summary.txt"
    csv_files = sorted(Path(output_dir).glob("*.csv"))

    with open(summary_path, "w") as f:
        f.write("Demo Data Generation Summary\n")
        f.write(f"{'='*40}\n")
        f.write(f"Date range: {config.START_DATE} to {config.END_DATE}\n")
        f.write(f"Generation time: {elapsed:.1f}s\n\n")

        f.write("CSV files:\n")
        total_rows = 0
        for csv_file in csv_files:
            line_count = sum(1 for _ in open(csv_file)) - 1  # exclude header
            total_rows += line_count
            f.write(f"  {csv_file.name}: {line_count:,} rows\n")

        f.write(f"\nTotal: {len(csv_files)} files, {total_rows:,} rows\n")

        f.write("\nNarrative checkpoints:\n")
        f.write(f"  Struggling location decline: {config.NARRATIVES['struggling_location']['decline_start']}\n")
        f.write(f"  Margin squeeze hike 1: {config.NARRATIVES['margin_squeeze']['hike_1_date']}\n")
        f.write(f"  Margin squeeze hike 2: {config.NARRATIVES['margin_squeeze']['hike_2_date']}\n")

    print(f"Summary written to {summary_path}")


if __name__ == "__main__":
    main()
```

- [ ] **Step 2: Run full generation**

Restore full date range in config.py, then:

```bash
cd ClaudeDevelopment/demo-data
python generate.py
```

Expected: Completes in ~30-60 seconds, produces ~52 CSV files in `output/`. Check `output/summary.txt` for row counts.

- [ ] **Step 3: Commit**

```bash
git add ClaudeDevelopment/demo-data/generate.py
git commit -m "feat(demo-data): main orchestrator with summary report"
```

---

### Task 10: SQL Loader Script

**Files:**
- Create: `ClaudeDevelopment/demo-data/load_demo_data.sql`

- [ ] **Step 1: Write the loader script**

The script uses the **staging table approach** for BINARY(32) conversion:
1. For each DV table, create a `#staging_{table}` temp table with NVARCHAR columns for hex fields
2. BULK INSERT CSV into the staging table
3. INSERT into the real DV table with `CONVERT(BINARY(32), hex_col, 2)` for hash columns

Structure:
```sql
-- ============================================
-- Demo Data Loader for "The Oak & Vine"
-- ============================================
-- Set these two variables before running:
DECLARE @CsvPath NVARCHAR(500) = N'C:\path\to\demo-data\output';
DECLARE @DatabaseName NVARCHAR(255) = N'20260316_XMS_{GUID}';

-- Uncomment for regeneration (wipes existing demo data):
-- EXEC('USE [' + @DatabaseName + '] TRUNCATE TABLE [datavault].[HUB_LOCATION] ...')

-- Phase 0: GlobalParameters
-- INSERT LINEITEM_START, LINEITEM_END, STOCKEVENT_START, STOCKEVENT_END

-- Phase 1: Hubs (14 tables)
-- Phase 2: Satellites (14 tables)
-- Phase 3: Links (19 tables)
-- Phase 4: Link satellites (5 tables)

-- Post-load:
-- EXEC [{db}].[core].[sp_PopulateCalendar] @YearsBefore = 2, @YearsAfter = 2
-- EXEC [{db}].[core].[sp_ProcessPresentation]
```

Each table load follows this pattern:
```sql
-- Load HUB_LOCATION
PRINT 'Loading HUB_LOCATION...'
BEGIN TRY
    CREATE TABLE #stg_hub_location (
        HUB_ID NVARCHAR(64),
        SRC NVARCHAR(255),
        IS_DELETED NVARCHAR(1),
        LOAD_TS NVARCHAR(50)
    );

    DECLARE @sql NVARCHAR(MAX) = N'BULK INSERT #stg_hub_location
        FROM ''' + @CsvPath + N'\hub_location.csv''
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ''|'', ROWTERMINATOR = ''\n'',
              CODEPAGE = ''65001'', TABLOCK)';
    EXEC sp_executesql @sql;

    DECLARE @insert NVARCHAR(MAX) = N'INSERT INTO [' + @DatabaseName + N'].[datavault].[HUB_LOCATION]
        (HUB_ID, SRC, IS_DELETED, LOAD_TS)
        SELECT CONVERT(BINARY(32), HUB_ID, 2), SRC,
               CONVERT(BIT, IS_DELETED), CONVERT(DATETIME2, LOAD_TS)
        FROM #stg_hub_location';
    EXEC sp_executesql @insert;

    DROP TABLE #stg_hub_location;
    PRINT '  OK'
END TRY
BEGIN CATCH
    PRINT '  FAILED: ' + ERROR_MESSAGE()
    RETURN
END CATCH
```

The script is long (~800-1000 lines) because it repeats this pattern for all 52 tables with table-specific column lists. The Phase 0 GlobalParameters section and post-load EXEC calls are at the end.

- [ ] **Step 2: Verify script syntax**

Open in SSMS and verify it parses without errors (don't execute yet).

- [ ] **Step 3: Commit**

```bash
git add ClaudeDevelopment/demo-data/load_demo_data.sql
git commit -m "feat(demo-data): SQL loader with staging tables for BINARY(32) conversion"
```

---

### Task 11: Integration Test

- [ ] **Step 1: Run full generation and verify output**

```bash
cd ClaudeDevelopment/demo-data
python generate.py --output-dir output
```

Check `output/summary.txt` for expected row counts:
- hub_custorder.csv: ~55K
- hub_lineitem.csv: ~150K
- hub_stockevent.csv: ~3K
- Total files: ~52
- Total rows: ~420K

- [ ] **Step 2: Spot-check referential integrity**

Write a quick Python verification script that checks:
- Every HUB_ID in a SAT file exists in the corresponding HUB file
- Every HUB_ID referenced by a LNK file exists in the source HUB file
- Every LNK_ID in a SAT_LNK file exists in the corresponding LNK file
- No duplicate HUB_IDs within a single hub file

```bash
cd ClaudeDevelopment/demo-data
python -c "
# Quick referential integrity check
import csv
from pathlib import Path

output = Path('output')

def load_ids(filename, col='HUB_ID'):
    ids = set()
    with open(output / filename, encoding='utf-8-sig') as f:
        reader = csv.DictReader(f, delimiter='|')
        for row in reader:
            ids.add(row[col])
    return ids

# Check SAT references HUB
hub_ids = load_ids('hub_product.csv')
sat_ids = load_ids('sat_product.csv')
orphans = sat_ids - hub_ids
print(f'Product SAT orphans: {len(orphans)} (should be 0)')

# Check LNK references HUBs
lnk_product_ids = set()
with open(output / 'lnk_lineitem_product.csv', encoding='utf-8-sig') as f:
    reader = csv.DictReader(f, delimiter='|')
    for row in reader:
        lnk_product_ids.add(row['PRODUCT_HUB_ID'])
orphans = lnk_product_ids - hub_ids
print(f'LNK_LINEITEM_PRODUCT → HUB_PRODUCT orphans: {len(orphans)} (should be 0)')
print('Integrity check passed!' if len(orphans) == 0 else 'ISSUES FOUND')
"
```

- [ ] **Step 3: Verify narrative effects are visible**

```bash
cd ClaudeDevelopment/demo-data
python -c "
import csv
from pathlib import Path
from collections import Counter

output = Path('output')

# Check Edinburgh Old Town has fewer orders in March vs October
with open(output / 'sat_custorder.csv', encoding='utf-8-sig') as f:
    reader = csv.DictReader(f, delimiter='|')
    # Count orders by month (approximate via ORDER_DATE)
    month_counts = Counter()
    for row in reader:
        od = row.get('ORDER_DATE', '')
        if od:
            month = od[:7]  # YYYY-MM
            month_counts[month] += 1

for month in sorted(month_counts):
    print(f'{month}: {month_counts[month]:,} orders')
print()
print('March should be lower than October if struggling location narrative works.')
"
```

- [ ] **Step 4: Add .gitignore for output directory**

```bash
echo '*' > ClaudeDevelopment/demo-data/output/.gitignore
echo '!.gitignore' >> ClaudeDevelopment/demo-data/output/.gitignore
```

- [ ] **Step 5: Final commit**

```bash
git add ClaudeDevelopment/demo-data/
git commit -m "feat(demo-data): integration tests + output gitignore"
```

---

### Task 12: Report Database Config Script (follow-up)

**Files:**
- Create: `ClaudeDevelopment/demo-data/report_db_config.sql`

This task creates the microservice report DB configuration so the front end knows which dashboard cards to render for the demo org. Follows the same pattern as `ClaudeDevelopment/Deploy/growyze_report_db_dev.sql`.

- [ ] **Step 1: Write report_db_config.sql**

INSERT records into:
- `BiConfig` — maps demo org to its MI database
- `VisualisationConfig` — enables vis query datasets for the demo org
- `VisualisationDataSetMap` — wires datasets to card types
- `DashboardGrid` — defines dashboard layouts (e.g. Sales, Inventory, Products)
- `DashboardItem` — places cards on grids
- `DashboardFilter` — adds filter dropdowns
- `OrganisationDashboardConfig` — enables dashboards for the demo org

Remember: `TransactionId` is IDENTITY (never include), `IsDeleted` has no DEFAULT (must pass `0`).

- [ ] **Step 2: Commit**

```bash
git add ClaudeDevelopment/demo-data/report_db_config.sql
git commit -m "feat(demo-data): report DB config for The Oak & Vine demo org"
```

---

## Deployment Checklist

After all tasks are complete:

1. [ ] Provision demo org via standard SPs (AddOrganisation, sp_DeployObjects, MapOrganisationToIntegration, DeployPresentationTables)
2. [ ] Update `config.py` POS_SRC and INVENTORY_SRC to match the actual integration schemas mapped to the demo org
3. [ ] Run `python generate.py`
4. [ ] Copy output CSVs to a path accessible from the SQL Server instance
5. [ ] Update `load_demo_data.sql` with correct `@CsvPath` and `@DatabaseName`
6. [ ] Execute loader in SSMS
7. [ ] Verify presentation build completes: `sp_PopulateCalendar` then `sp_ProcessPresentation`
8. [ ] Create report DB config (BiConfig, VisualisationConfig, DashboardGrid/Item/Filter)
9. [ ] Spot-check dashboards in the front end
