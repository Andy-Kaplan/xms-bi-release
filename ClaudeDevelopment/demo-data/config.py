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

# ── Inventory Items (~120 ingredients) ──────────────────────
INVITEM_CATEGORIES = [
    {"id": "INVCAT_PROT", "name": "Proteins"},
    {"id": "INVCAT_PROD", "name": "Produce"},
    {"id": "INVCAT_DAIR", "name": "Dairy"},
    {"id": "INVCAT_DRY",  "name": "Dry Goods"},
    {"id": "INVCAT_BEV",  "name": "Beverages"},
    {"id": "INVCAT_COFF", "name": "Coffee & Tea"},
]

INVITEM_SUPER_CATEGORY = {"id": "INVCAT_ALL", "name": "All Ingredients"}

INVITEMS = [
    # --- Proteins (20) ---
    {"id": "INV001", "name": "Beef Fillet",           "cat": "INVCAT_PROT", "uom": "kg",  "cost": 8.50,  "supplier": "SUP001"},
    {"id": "INV002", "name": "Chicken Breast",         "cat": "INVCAT_PROT", "uom": "kg",  "cost": 4.20,  "supplier": "SUP001"},
    {"id": "INV003", "name": "Lamb Shank",             "cat": "INVCAT_PROT", "uom": "kg",  "cost": 7.80,  "supplier": "SUP001"},
    {"id": "INV004", "name": "Pork Belly",             "cat": "INVCAT_PROT", "uom": "kg",  "cost": 5.20,  "supplier": "SUP001"},
    {"id": "INV005", "name": "Ribeye Steak",           "cat": "INVCAT_PROT", "uom": "kg",  "cost": 9.00,  "supplier": "SUP001"},
    {"id": "INV006", "name": "Sea Bass Fillet",        "cat": "INVCAT_PROT", "uom": "kg",  "cost": 9.50,  "supplier": "SUP001"},
    {"id": "INV007", "name": "Salmon Fillet",          "cat": "INVCAT_PROT", "uom": "kg",  "cost": 8.00,  "supplier": "SUP001"},
    {"id": "INV008", "name": "Tiger Prawns",           "cat": "INVCAT_PROT", "uom": "kg",  "cost": 12.00, "supplier": "SUP001"},
    {"id": "INV009", "name": "Cod Fillet",             "cat": "INVCAT_PROT", "uom": "kg",  "cost": 7.20,  "supplier": "SUP001"},
    {"id": "INV010", "name": "Duck Breast",            "cat": "INVCAT_PROT", "uom": "kg",  "cost": 8.80,  "supplier": "SUP001"},
    {"id": "INV011", "name": "Halloumi",               "cat": "INVCAT_PROT", "uom": "kg",  "cost": 6.50,  "supplier": "SUP001"},
    {"id": "INV012", "name": "Plant Protein Patty",   "cat": "INVCAT_PROT", "uom": "each","cost": 1.80,  "supplier": "SUP001"},
    {"id": "INV013", "name": "Beef Mince",             "cat": "INVCAT_PROT", "uom": "kg",  "cost": 5.80,  "supplier": "SUP001"},
    {"id": "INV014", "name": "Pulled Pork",            "cat": "INVCAT_PROT", "uom": "kg",  "cost": 5.50,  "supplier": "SUP001"},
    {"id": "INV015", "name": "Chicken Thigh",          "cat": "INVCAT_PROT", "uom": "kg",  "cost": 3.50,  "supplier": "SUP001"},
    {"id": "INV016", "name": "Lamb Mince",             "cat": "INVCAT_PROT", "uom": "kg",  "cost": 7.20,  "supplier": "SUP001"},
    {"id": "INV017", "name": "Calamari Rings",         "cat": "INVCAT_PROT", "uom": "kg",  "cost": 6.80,  "supplier": "SUP001"},
    {"id": "INV018", "name": "Bacon Rashers",          "cat": "INVCAT_PROT", "uom": "kg",  "cost": 4.80,  "supplier": "SUP001"},
    {"id": "INV019", "name": "Chicken Wing",           "cat": "INVCAT_PROT", "uom": "kg",  "cost": 3.20,  "supplier": "SUP001"},
    {"id": "INV020", "name": "Chorizo",                "cat": "INVCAT_PROT", "uom": "kg",  "cost": 7.50,  "supplier": "SUP001"},
    # --- Produce (25) ---
    {"id": "INV021", "name": "Iceberg Lettuce",        "cat": "INVCAT_PROD", "uom": "each","cost": 0.80,  "supplier": "SUP002"},
    {"id": "INV022", "name": "Cherry Tomatoes",        "cat": "INVCAT_PROD", "uom": "kg",  "cost": 2.50,  "supplier": "SUP002"},
    {"id": "INV023", "name": "Red Onion",              "cat": "INVCAT_PROD", "uom": "kg",  "cost": 1.20,  "supplier": "SUP002"},
    {"id": "INV024", "name": "White Onion",            "cat": "INVCAT_PROD", "uom": "kg",  "cost": 1.00,  "supplier": "SUP002"},
    {"id": "INV025", "name": "Maris Piper Potato",    "cat": "INVCAT_PROD", "uom": "kg",  "cost": 0.60,  "supplier": "SUP002"},
    {"id": "INV026", "name": "Sweet Potato",           "cat": "INVCAT_PROD", "uom": "kg",  "cost": 1.20,  "supplier": "SUP002"},
    {"id": "INV027", "name": "Chestnut Mushroom",      "cat": "INVCAT_PROD", "uom": "kg",  "cost": 3.50,  "supplier": "SUP002"},
    {"id": "INV028", "name": "Garlic Bulb",            "cat": "INVCAT_PROD", "uom": "kg",  "cost": 2.80,  "supplier": "SUP002"},
    {"id": "INV029", "name": "Fresh Basil",            "cat": "INVCAT_PROD", "uom": "kg",  "cost": 12.00, "supplier": "SUP002"},
    {"id": "INV030", "name": "Fresh Parsley",          "cat": "INVCAT_PROD", "uom": "kg",  "cost": 10.00, "supplier": "SUP002"},
    {"id": "INV031", "name": "Fresh Rosemary",         "cat": "INVCAT_PROD", "uom": "kg",  "cost": 11.00, "supplier": "SUP002"},
    {"id": "INV032", "name": "Fresh Thyme",            "cat": "INVCAT_PROD", "uom": "kg",  "cost": 11.00, "supplier": "SUP002"},
    {"id": "INV033", "name": "Broccoli",               "cat": "INVCAT_PROD", "uom": "kg",  "cost": 2.20,  "supplier": "SUP002"},
    {"id": "INV034", "name": "Courgette",              "cat": "INVCAT_PROD", "uom": "kg",  "cost": 2.00,  "supplier": "SUP002"},
    {"id": "INV035", "name": "Red Pepper",             "cat": "INVCAT_PROD", "uom": "kg",  "cost": 2.80,  "supplier": "SUP002"},
    {"id": "INV036", "name": "Spinach",                "cat": "INVCAT_PROD", "uom": "kg",  "cost": 4.00,  "supplier": "SUP002"},
    {"id": "INV037", "name": "Cucumber",               "cat": "INVCAT_PROD", "uom": "each","cost": 0.70,  "supplier": "SUP002"},
    {"id": "INV038", "name": "Lemon",                  "cat": "INVCAT_PROD", "uom": "each","cost": 0.30,  "supplier": "SUP002"},
    {"id": "INV039", "name": "Lime",                   "cat": "INVCAT_PROD", "uom": "each","cost": 0.25,  "supplier": "SUP002"},
    {"id": "INV040", "name": "Apple",                  "cat": "INVCAT_PROD", "uom": "each","cost": 0.35,  "supplier": "SUP002"},
    {"id": "INV041", "name": "Mango",                  "cat": "INVCAT_PROD", "uom": "each","cost": 0.90,  "supplier": "SUP002"},
    {"id": "INV042", "name": "Carrot",                 "cat": "INVCAT_PROD", "uom": "kg",  "cost": 0.80,  "supplier": "SUP002"},
    {"id": "INV043", "name": "Celery",                 "cat": "INVCAT_PROD", "uom": "each","cost": 0.90,  "supplier": "SUP002"},
    {"id": "INV044", "name": "Fennel",                 "cat": "INVCAT_PROD", "uom": "each","cost": 1.20,  "supplier": "SUP002"},
    {"id": "INV045", "name": "Rocket",                 "cat": "INVCAT_PROD", "uom": "kg",  "cost": 8.00,  "supplier": "SUP002"},
    # --- Dairy (15) ---
    {"id": "INV046", "name": "Double Cream",           "cat": "INVCAT_DAIR", "uom": "L",   "cost": 2.80,  "supplier": "SUP003"},
    {"id": "INV047", "name": "Unsalted Butter",        "cat": "INVCAT_DAIR", "uom": "kg",  "cost": 5.50,  "supplier": "SUP003"},
    {"id": "INV048", "name": "Cheddar Cheese",         "cat": "INVCAT_DAIR", "uom": "kg",  "cost": 7.00,  "supplier": "SUP003"},
    {"id": "INV049", "name": "Parmesan",               "cat": "INVCAT_DAIR", "uom": "kg",  "cost": 14.00, "supplier": "SUP003"},
    {"id": "INV050", "name": "Mozzarella",             "cat": "INVCAT_DAIR", "uom": "kg",  "cost": 8.00,  "supplier": "SUP003"},
    {"id": "INV051", "name": "Brie",                   "cat": "INVCAT_DAIR", "uom": "kg",  "cost": 10.50, "supplier": "SUP003"},
    {"id": "INV052", "name": "Stilton",                "cat": "INVCAT_DAIR", "uom": "kg",  "cost": 12.00, "supplier": "SUP003"},
    {"id": "INV053", "name": "Whole Milk",             "cat": "INVCAT_DAIR", "uom": "L",   "cost": 0.80,  "supplier": "SUP003"},
    {"id": "INV054", "name": "Free Range Eggs",        "cat": "INVCAT_DAIR", "uom": "each","cost": 0.28,  "supplier": "SUP003"},
    {"id": "INV055", "name": "Creme Fraiche",          "cat": "INVCAT_DAIR", "uom": "kg",  "cost": 3.50,  "supplier": "SUP003"},
    {"id": "INV056", "name": "Greek Yoghurt",          "cat": "INVCAT_DAIR", "uom": "kg",  "cost": 3.00,  "supplier": "SUP003"},
    {"id": "INV057", "name": "Goat Cheese",            "cat": "INVCAT_DAIR", "uom": "kg",  "cost": 11.00, "supplier": "SUP003"},
    {"id": "INV058", "name": "Oat Milk",               "cat": "INVCAT_DAIR", "uom": "L",   "cost": 1.50,  "supplier": "SUP003"},
    {"id": "INV059", "name": "Soy Milk",               "cat": "INVCAT_DAIR", "uom": "L",   "cost": 1.40,  "supplier": "SUP003"},
    {"id": "INV060", "name": "Mascarpone",             "cat": "INVCAT_DAIR", "uom": "kg",  "cost": 6.00,  "supplier": "SUP003"},
    # --- Dry Goods (25) ---
    {"id": "INV061", "name": "Plain Flour",            "cat": "INVCAT_DRY",  "uom": "kg",  "cost": 0.90,  "supplier": "SUP004"},
    {"id": "INV062", "name": "Breadcrumbs",            "cat": "INVCAT_DRY",  "uom": "kg",  "cost": 2.20,  "supplier": "SUP004"},
    {"id": "INV063", "name": "Penne Pasta",            "cat": "INVCAT_DRY",  "uom": "kg",  "cost": 1.80,  "supplier": "SUP004"},
    {"id": "INV064", "name": "Linguine",               "cat": "INVCAT_DRY",  "uom": "kg",  "cost": 2.00,  "supplier": "SUP004"},
    {"id": "INV065", "name": "Arborio Rice",           "cat": "INVCAT_DRY",  "uom": "kg",  "cost": 2.50,  "supplier": "SUP004"},
    {"id": "INV066", "name": "Olive Oil",              "cat": "INVCAT_DRY",  "uom": "L",   "cost": 4.00,  "supplier": "SUP004"},
    {"id": "INV067", "name": "Sunflower Oil",          "cat": "INVCAT_DRY",  "uom": "L",   "cost": 1.50,  "supplier": "SUP004"},
    {"id": "INV068", "name": "Tomato Passata",         "cat": "INVCAT_DRY",  "uom": "L",   "cost": 1.60,  "supplier": "SUP004"},
    {"id": "INV069", "name": "Chicken Stock",          "cat": "INVCAT_DRY",  "uom": "L",   "cost": 1.20,  "supplier": "SUP004"},
    {"id": "INV070", "name": "Beef Stock",             "cat": "INVCAT_DRY",  "uom": "L",   "cost": 1.40,  "supplier": "SUP004"},
    {"id": "INV071", "name": "Soy Sauce",              "cat": "INVCAT_DRY",  "uom": "L",   "cost": 3.50,  "supplier": "SUP004"},
    {"id": "INV072", "name": "Worcestershire Sauce",  "cat": "INVCAT_DRY",  "uom": "L",   "cost": 4.20,  "supplier": "SUP004"},
    {"id": "INV073", "name": "Dijon Mustard",          "cat": "INVCAT_DRY",  "uom": "kg",  "cost": 5.00,  "supplier": "SUP004"},
    {"id": "INV074", "name": "Honey",                  "cat": "INVCAT_DRY",  "uom": "kg",  "cost": 6.00,  "supplier": "SUP004"},
    {"id": "INV075", "name": "Sea Salt",               "cat": "INVCAT_DRY",  "uom": "kg",  "cost": 1.80,  "supplier": "SUP004"},
    {"id": "INV076", "name": "Black Pepper",           "cat": "INVCAT_DRY",  "uom": "kg",  "cost": 8.00,  "supplier": "SUP004"},
    {"id": "INV077", "name": "Paprika",                "cat": "INVCAT_DRY",  "uom": "kg",  "cost": 6.00,  "supplier": "SUP004"},
    {"id": "INV078", "name": "Cumin",                  "cat": "INVCAT_DRY",  "uom": "kg",  "cost": 7.00,  "supplier": "SUP004"},
    {"id": "INV079", "name": "Brioche Bun",            "cat": "INVCAT_DRY",  "uom": "each","cost": 0.45,  "supplier": "SUP004"},
    {"id": "INV080", "name": "Sourdough Bread",        "cat": "INVCAT_DRY",  "uom": "each","cost": 0.60,  "supplier": "SUP004"},
    {"id": "INV081", "name": "Crackers",               "cat": "INVCAT_DRY",  "uom": "each","cost": 0.30,  "supplier": "SUP004"},
    {"id": "INV082", "name": "Panko Breadcrumbs",      "cat": "INVCAT_DRY",  "uom": "kg",  "cost": 3.00,  "supplier": "SUP004"},
    {"id": "INV083", "name": "Cornstarch",             "cat": "INVCAT_DRY",  "uom": "kg",  "cost": 2.00,  "supplier": "SUP004"},
    {"id": "INV084", "name": "Brown Sugar",            "cat": "INVCAT_DRY",  "uom": "kg",  "cost": 1.50,  "supplier": "SUP004"},
    {"id": "INV085", "name": "Caster Sugar",           "cat": "INVCAT_DRY",  "uom": "kg",  "cost": 1.40,  "supplier": "SUP004"},
    # --- Beverages (25) ---
    {"id": "INV086", "name": "Vodka",                  "cat": "INVCAT_BEV",  "uom": "L",   "cost": 12.00, "supplier": "SUP005"},
    {"id": "INV087", "name": "Gin",                    "cat": "INVCAT_BEV",  "uom": "L",   "cost": 14.00, "supplier": "SUP005"},
    {"id": "INV088", "name": "White Rum",              "cat": "INVCAT_BEV",  "uom": "L",   "cost": 11.00, "supplier": "SUP005"},
    {"id": "INV089", "name": "Dark Rum",               "cat": "INVCAT_BEV",  "uom": "L",   "cost": 12.50, "supplier": "SUP005"},
    {"id": "INV090", "name": "Bourbon Whiskey",        "cat": "INVCAT_BEV",  "uom": "L",   "cost": 16.00, "supplier": "SUP005"},
    {"id": "INV091", "name": "Scotch Whisky",          "cat": "INVCAT_BEV",  "uom": "L",   "cost": 18.00, "supplier": "SUP005"},
    {"id": "INV092", "name": "Tequila",                "cat": "INVCAT_BEV",  "uom": "L",   "cost": 13.50, "supplier": "SUP005"},
    {"id": "INV093", "name": "Aperol",                 "cat": "INVCAT_BEV",  "uom": "L",   "cost": 10.00, "supplier": "SUP005"},
    {"id": "INV094", "name": "Sweet Vermouth",         "cat": "INVCAT_BEV",  "uom": "L",   "cost": 8.00,  "supplier": "SUP005"},
    {"id": "INV095", "name": "Campari",                "cat": "INVCAT_BEV",  "uom": "L",   "cost": 11.00, "supplier": "SUP005"},
    {"id": "INV096", "name": "Prosecco (Bulk)",        "cat": "INVCAT_BEV",  "uom": "L",   "cost": 5.00,  "supplier": "SUP005"},
    {"id": "INV097", "name": "House Red Wine",         "cat": "INVCAT_BEV",  "uom": "L",   "cost": 4.50,  "supplier": "SUP005"},
    {"id": "INV098", "name": "House White Wine",       "cat": "INVCAT_BEV",  "uom": "L",   "cost": 4.20,  "supplier": "SUP005"},
    {"id": "INV099", "name": "House Rose Wine",        "cat": "INVCAT_BEV",  "uom": "L",   "cost": 4.20,  "supplier": "SUP005"},
    {"id": "INV100", "name": "IPA Keg",                "cat": "INVCAT_BEV",  "uom": "L",   "cost": 2.80,  "supplier": "SUP005"},
    {"id": "INV101", "name": "Lager Keg",              "cat": "INVCAT_BEV",  "uom": "L",   "cost": 2.20,  "supplier": "SUP005"},
    {"id": "INV102", "name": "Stout Keg",              "cat": "INVCAT_BEV",  "uom": "L",   "cost": 2.60,  "supplier": "SUP005"},
    {"id": "INV103", "name": "Pale Ale Keg",           "cat": "INVCAT_BEV",  "uom": "L",   "cost": 2.70,  "supplier": "SUP005"},
    {"id": "INV104", "name": "Cider Keg",              "cat": "INVCAT_BEV",  "uom": "L",   "cost": 2.30,  "supplier": "SUP005"},
    {"id": "INV105", "name": "Cola Syrup",             "cat": "INVCAT_BEV",  "uom": "L",   "cost": 2.50,  "supplier": "SUP005"},
    {"id": "INV106", "name": "Lemonade Syrup",         "cat": "INVCAT_BEV",  "uom": "L",   "cost": 2.40,  "supplier": "SUP005"},
    {"id": "INV107", "name": "Elderflower Cordial",   "cat": "INVCAT_BEV",  "uom": "L",   "cost": 5.50,  "supplier": "SUP005"},
    {"id": "INV108", "name": "Ginger Beer (Bottle)",  "cat": "INVCAT_BEV",  "uom": "each","cost": 0.80,  "supplier": "SUP005"},
    {"id": "INV109", "name": "Coconut Cream",          "cat": "INVCAT_BEV",  "uom": "L",   "cost": 3.20,  "supplier": "SUP005"},
    {"id": "INV110", "name": "Angostura Bitters",      "cat": "INVCAT_BEV",  "uom": "L",   "cost": 22.00, "supplier": "SUP005"},
    # --- Coffee & Tea (10) ---
    {"id": "INV111", "name": "Espresso Beans",         "cat": "INVCAT_COFF", "uom": "kg",  "cost": 18.00, "supplier": "SUP006"},
    {"id": "INV112", "name": "English Breakfast Tea", "cat": "INVCAT_COFF", "uom": "kg",  "cost": 12.00, "supplier": "SUP006"},
    {"id": "INV113", "name": "Green Tea",              "cat": "INVCAT_COFF", "uom": "kg",  "cost": 16.00, "supplier": "SUP006"},
    {"id": "INV114", "name": "Peppermint Tea",         "cat": "INVCAT_COFF", "uom": "kg",  "cost": 15.00, "supplier": "SUP006"},
    {"id": "INV115", "name": "Hot Chocolate Powder",  "cat": "INVCAT_COFF", "uom": "kg",  "cost": 8.00,  "supplier": "SUP006"},
    {"id": "INV116", "name": "Vanilla Syrup",          "cat": "INVCAT_COFF", "uom": "L",   "cost": 6.00,  "supplier": "SUP006"},
    {"id": "INV117", "name": "Caramel Syrup",          "cat": "INVCAT_COFF", "uom": "L",   "cost": 6.00,  "supplier": "SUP006"},
    {"id": "INV118", "name": "Hazelnut Syrup",         "cat": "INVCAT_COFF", "uom": "L",   "cost": 6.50,  "supplier": "SUP006"},
    {"id": "INV119", "name": "Decaf Espresso Beans",  "cat": "INVCAT_COFF", "uom": "kg",  "cost": 20.00, "supplier": "SUP006"},
    {"id": "INV120", "name": "Chai Syrup",             "cat": "INVCAT_COFF", "uom": "L",   "cost": 7.00,  "supplier": "SUP006"},
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

# ── Recipes ─────────────────────────────────────────────────
# Maps each product_id to a list of (invitem_id, quantity, uom) tuples.
# Quantities represent a single serving.
# NOTE: The margin_squeeze narrative calls for INV001 (Beef Fillet) in PROD011
# (8oz Ribeye) — the recipe generator will emit 3 cost-history rows for that
# ingredient to simulate the supplier price hikes.
RECIPES = {
    # --- Starters (10) ---
    "PROD001": [  # Soup of the Day
        ("INV024", 0.15, "kg"),   # White Onion
        ("INV042", 0.10, "kg"),   # Carrot
        ("INV043", 0.05, "each"), # Celery
        ("INV069", 0.20, "L"),    # Chicken Stock
        ("INV046", 0.05, "L"),    # Double Cream
    ],
    "PROD002": [  # Prawn Cocktail
        ("INV008", 0.12, "kg"),   # Tiger Prawns
        ("INV021", 0.06, "each"), # Iceberg Lettuce
        ("INV038", 0.25, "each"), # Lemon
        ("INV055", 0.03, "kg"),   # Creme Fraiche
        ("INV022", 0.05, "kg"),   # Cherry Tomatoes
    ],
    "PROD003": [  # Halloumi Fries
        ("INV011", 0.12, "kg"),   # Halloumi
        ("INV061", 0.03, "kg"),   # Plain Flour
        ("INV067", 0.05, "L"),    # Sunflower Oil
        ("INV075", 0.005, "kg"),  # Sea Salt
    ],
    "PROD004": [  # Chicken Wings
        ("INV019", 0.25, "kg"),   # Chicken Wing
        ("INV074", 0.02, "kg"),   # Honey
        ("INV071", 0.02, "L"),    # Soy Sauce
        ("INV077", 0.005, "kg"),  # Paprika
        ("INV028", 0.01, "kg"),   # Garlic Bulb
    ],
    "PROD005": [  # Bruschetta
        ("INV080", 2.0, "each"),  # Sourdough Bread
        ("INV022", 0.10, "kg"),   # Cherry Tomatoes
        ("INV029", 0.005, "kg"),  # Fresh Basil
        ("INV066", 0.02, "L"),    # Olive Oil
        ("INV028", 0.01, "kg"),   # Garlic Bulb
    ],
    "PROD006": [  # Scotch Egg
        ("INV054", 2.0, "each"),  # Free Range Eggs
        ("INV013", 0.10, "kg"),   # Beef Mince
        ("INV062", 0.05, "kg"),   # Breadcrumbs
        ("INV076", 0.005, "kg"),  # Black Pepper
        ("INV067", 0.05, "L"),    # Sunflower Oil
    ],
    "PROD007": [  # Calamari
        ("INV017", 0.15, "kg"),   # Calamari Rings
        ("INV082", 0.05, "kg"),   # Panko Breadcrumbs
        ("INV061", 0.03, "kg"),   # Plain Flour
        ("INV067", 0.08, "L"),    # Sunflower Oil
        ("INV038", 0.5, "each"),  # Lemon
    ],
    "PROD008": [  # Garlic Mushrooms
        ("INV027", 0.20, "kg"),   # Chestnut Mushroom
        ("INV028", 0.02, "kg"),   # Garlic Bulb
        ("INV047", 0.03, "kg"),   # Unsalted Butter
        ("INV030", 0.005, "kg"),  # Fresh Parsley
        ("INV080", 1.0, "each"),  # Sourdough Bread
    ],
    "PROD009": [  # Pâté & Toast
        ("INV018", 0.08, "kg"),   # Bacon Rashers
        ("INV047", 0.04, "kg"),   # Unsalted Butter
        ("INV080", 2.0, "each"),  # Sourdough Bread
        ("INV073", 0.01, "kg"),   # Dijon Mustard
        ("INV038", 0.5, "each"),  # Lemon
    ],
    "PROD010": [  # Caprese Salad
        ("INV050", 0.12, "kg"),   # Mozzarella
        ("INV022", 0.12, "kg"),   # Cherry Tomatoes
        ("INV029", 0.005, "kg"),  # Fresh Basil
        ("INV066", 0.02, "L"),    # Olive Oil
        ("INV075", 0.003, "kg"),  # Sea Salt
    ],
    # --- Mains (15) ---
    "PROD011": [  # 8oz Ribeye — margin squeeze hero (INV001 gets cost history rows)
        ("INV001", 0.25, "kg"),   # Beef Fillet  ← narrative cost hikes here
        ("INV025", 0.20, "kg"),   # Maris Piper Potato
        ("INV033", 0.12, "kg"),   # Broccoli
        ("INV047", 0.02, "kg"),   # Unsalted Butter
        ("INV070", 0.10, "L"),    # Beef Stock
    ],
    "PROD012": [  # Chicken Supreme
        ("INV002", 0.22, "kg"),   # Chicken Breast
        ("INV027", 0.12, "kg"),   # Chestnut Mushroom
        ("INV069", 0.15, "L"),    # Chicken Stock
        ("INV046", 0.05, "L"),    # Double Cream
        ("INV031", 0.005, "kg"),  # Fresh Rosemary
    ],
    "PROD013": [  # Fish & Chips
        ("INV009", 0.20, "kg"),   # Cod Fillet
        ("INV025", 0.25, "kg"),   # Maris Piper Potato
        ("INV061", 0.05, "kg"),   # Plain Flour
        ("INV067", 0.10, "L"),    # Sunflower Oil
        ("INV038", 0.5, "each"),  # Lemon
    ],
    "PROD014": [  # Mushroom Risotto
        ("INV065", 0.12, "kg"),   # Arborio Rice
        ("INV027", 0.18, "kg"),   # Chestnut Mushroom
        ("INV049", 0.03, "kg"),   # Parmesan
        ("INV047", 0.03, "kg"),   # Unsalted Butter
        ("INV069", 0.30, "L"),    # Chicken Stock
    ],
    "PROD015": [  # Lamb Shank
        ("INV003", 0.40, "kg"),   # Lamb Shank
        ("INV024", 0.10, "kg"),   # White Onion
        ("INV070", 0.20, "L"),    # Beef Stock
        ("INV031", 0.005, "kg"),  # Fresh Rosemary
        ("INV032", 0.005, "kg"),  # Fresh Thyme
    ],
    "PROD016": [  # Sea Bass Fillet
        ("INV006", 0.22, "kg"),   # Sea Bass Fillet
        ("INV044", 0.5, "each"),  # Fennel
        ("INV038", 0.5, "each"),  # Lemon
        ("INV066", 0.03, "L"),    # Olive Oil
        ("INV036", 0.05, "kg"),   # Spinach
    ],
    "PROD017": [  # Pork Belly
        ("INV004", 0.28, "kg"),   # Pork Belly
        ("INV025", 0.20, "kg"),   # Maris Piper Potato
        ("INV042", 0.10, "kg"),   # Carrot
        ("INV074", 0.02, "kg"),   # Honey
        ("INV031", 0.005, "kg"),  # Fresh Rosemary
    ],
    "PROD018": [  # Chicken Caesar Salad
        ("INV002", 0.18, "kg"),   # Chicken Breast
        ("INV021", 0.1, "each"),  # Iceberg Lettuce
        ("INV049", 0.02, "kg"),   # Parmesan
        ("INV073", 0.02, "kg"),   # Dijon Mustard
        ("INV054", 1.0, "each"),  # Free Range Eggs
    ],
    "PROD019": [  # Steak & Ale Pie
        ("INV013", 0.20, "kg"),   # Beef Mince
        ("INV024", 0.10, "kg"),   # White Onion
        ("INV070", 0.20, "L"),    # Beef Stock
        ("INV072", 0.02, "L"),    # Worcestershire Sauce
        ("INV061", 0.08, "kg"),   # Plain Flour
    ],
    "PROD020": [  # Grilled Salmon
        ("INV007", 0.22, "kg"),   # Salmon Fillet
        ("INV033", 0.10, "kg"),   # Broccoli
        ("INV038", 0.5, "each"),  # Lemon
        ("INV066", 0.02, "L"),    # Olive Oil
        ("INV030", 0.005, "kg"),  # Fresh Parsley
    ],
    "PROD021": [  # Veggie Tagine
        ("INV034", 0.15, "kg"),   # Courgette
        ("INV035", 0.15, "kg"),   # Red Pepper
        ("INV024", 0.10, "kg"),   # White Onion
        ("INV078", 0.01, "kg"),   # Cumin
        ("INV068", 0.15, "L"),    # Tomato Passata
    ],
    "PROD022": [  # Duck Breast
        ("INV010", 0.24, "kg"),   # Duck Breast
        ("INV045", 0.04, "kg"),   # Rocket
        ("INV074", 0.02, "kg"),   # Honey
        ("INV070", 0.10, "L"),    # Beef Stock
        ("INV040", 1.0, "each"),  # Apple
    ],
    "PROD023": [  # Prawn Linguine
        ("INV008", 0.15, "kg"),   # Tiger Prawns
        ("INV064", 0.10, "kg"),   # Linguine
        ("INV028", 0.01, "kg"),   # Garlic Bulb
        ("INV066", 0.03, "L"),    # Olive Oil
        ("INV038", 0.5, "each"),  # Lemon
    ],
    "PROD024": [  # Beef Bourguignon
        ("INV001", 0.22, "kg"),   # Beef Fillet
        ("INV023", 0.08, "kg"),   # Red Onion
        ("INV027", 0.12, "kg"),   # Chestnut Mushroom
        ("INV070", 0.20, "L"),    # Beef Stock
        ("INV032", 0.005, "kg"),  # Fresh Thyme
    ],
    "PROD025": [  # Goat Cheese Tart
        ("INV057", 0.10, "kg"),   # Goat Cheese
        ("INV061", 0.08, "kg"),   # Plain Flour
        ("INV054", 1.0, "each"),  # Free Range Eggs
        ("INV035", 0.08, "kg"),   # Red Pepper
        ("INV036", 0.04, "kg"),   # Spinach
    ],
    # --- Burgers (8) ---
    "PROD026": [  # Classic Burger
        ("INV013", 0.18, "kg"),   # Beef Mince
        ("INV079", 1.0, "each"),  # Brioche Bun
        ("INV021", 0.03, "each"), # Iceberg Lettuce
        ("INV022", 0.04, "kg"),   # Cherry Tomatoes
        ("INV073", 0.01, "kg"),   # Dijon Mustard
    ],
    "PROD027": [  # Oak & Vine Burger
        ("INV013", 0.20, "kg"),   # Beef Mince
        ("INV079", 1.0, "each"),  # Brioche Bun
        ("INV048", 0.04, "kg"),   # Cheddar Cheese
        ("INV018", 0.04, "kg"),   # Bacon Rashers
        ("INV023", 0.04, "kg"),   # Red Onion
    ],
    "PROD028": [  # Pulled Pork Burger
        ("INV014", 0.18, "kg"),   # Pulled Pork
        ("INV079", 1.0, "each"),  # Brioche Bun
        ("INV039", 0.25, "each"), # Lime
        ("INV077", 0.005, "kg"),  # Paprika
        ("INV021", 0.03, "each"), # Iceberg Lettuce
    ],
    "PROD029": [  # Plant Burger
        ("INV012", 1.0, "each"),  # Plant Protein Patty
        ("INV079", 1.0, "each"),  # Brioche Bun
        ("INV021", 0.03, "each"), # Iceberg Lettuce
        ("INV022", 0.04, "kg"),   # Cherry Tomatoes
        ("INV066", 0.01, "L"),    # Olive Oil
    ],
    "PROD030": [  # Chicken Burger
        ("INV015", 0.18, "kg"),   # Chicken Thigh
        ("INV079", 1.0, "each"),  # Brioche Bun
        ("INV056", 0.03, "kg"),   # Greek Yoghurt
        ("INV021", 0.03, "each"), # Iceberg Lettuce
        ("INV039", 0.5, "each"),  # Lime
    ],
    "PROD031": [  # Lamb Burger
        ("INV016", 0.18, "kg"),   # Lamb Mince
        ("INV079", 1.0, "each"),  # Brioche Bun
        ("INV056", 0.03, "kg"),   # Greek Yoghurt
        ("INV023", 0.04, "kg"),   # Red Onion
        ("INV029", 0.003, "kg"),  # Fresh Basil
    ],
    "PROD032": [  # Fish Burger
        ("INV009", 0.16, "kg"),   # Cod Fillet
        ("INV079", 1.0, "each"),  # Brioche Bun
        ("INV082", 0.04, "kg"),   # Panko Breadcrumbs
        ("INV021", 0.03, "each"), # Iceberg Lettuce
        ("INV038", 0.5, "each"),  # Lemon
    ],
    "PROD033": [  # Halloumi Burger
        ("INV011", 0.14, "kg"),   # Halloumi
        ("INV079", 1.0, "each"),  # Brioche Bun
        ("INV021", 0.03, "each"), # Iceberg Lettuce
        ("INV022", 0.04, "kg"),   # Cherry Tomatoes
        ("INV073", 0.01, "kg"),   # Dijon Mustard
    ],
    # --- Sides (8) ---
    "PROD034": [  # Chips
        ("INV025", 0.22, "kg"),   # Maris Piper Potato
        ("INV067", 0.05, "L"),    # Sunflower Oil
        ("INV075", 0.003, "kg"),  # Sea Salt
    ],
    "PROD035": [  # Sweet Potato Fries
        ("INV026", 0.22, "kg"),   # Sweet Potato
        ("INV067", 0.05, "L"),    # Sunflower Oil
        ("INV075", 0.003, "kg"),  # Sea Salt
    ],
    "PROD036": [  # House Salad
        ("INV021", 0.05, "each"), # Iceberg Lettuce
        ("INV022", 0.06, "kg"),   # Cherry Tomatoes
        ("INV037", 0.1, "each"),  # Cucumber
        ("INV066", 0.01, "L"),    # Olive Oil
        ("INV038", 0.25, "each"), # Lemon
    ],
    "PROD037": [  # Onion Rings
        ("INV024", 0.18, "kg"),   # White Onion
        ("INV061", 0.04, "kg"),   # Plain Flour
        ("INV053", 0.05, "L"),    # Whole Milk
        ("INV067", 0.08, "L"),    # Sunflower Oil
    ],
    "PROD038": [  # Bread Roll
        ("INV080", 1.0, "each"),  # Sourdough Bread
        ("INV047", 0.01, "kg"),   # Unsalted Butter
    ],
    "PROD039": [  # Coleslaw
        ("INV042", 0.10, "kg"),   # Carrot
        ("INV024", 0.06, "kg"),   # White Onion
        ("INV056", 0.05, "kg"),   # Greek Yoghurt
        ("INV073", 0.01, "kg"),   # Dijon Mustard
    ],
    "PROD040": [  # Mac & Cheese
        ("INV063", 0.12, "kg"),   # Penne Pasta
        ("INV048", 0.08, "kg"),   # Cheddar Cheese
        ("INV053", 0.10, "L"),    # Whole Milk
        ("INV047", 0.02, "kg"),   # Unsalted Butter
        ("INV061", 0.02, "kg"),   # Plain Flour
    ],
    "PROD041": [  # Seasonal Veg
        ("INV033", 0.10, "kg"),   # Broccoli
        ("INV034", 0.08, "kg"),   # Courgette
        ("INV042", 0.08, "kg"),   # Carrot
        ("INV047", 0.01, "kg"),   # Unsalted Butter
    ],
    # --- Desserts (8) ---
    "PROD042": [  # Sticky Toffee Pudding
        ("INV084", 0.06, "kg"),   # Brown Sugar
        ("INV047", 0.05, "kg"),   # Unsalted Butter
        ("INV054", 1.0, "each"),  # Free Range Eggs
        ("INV061", 0.08, "kg"),   # Plain Flour
        ("INV046", 0.05, "L"),    # Double Cream
    ],
    "PROD043": [  # Chocolate Brownie
        ("INV085", 0.08, "kg"),   # Caster Sugar
        ("INV047", 0.06, "kg"),   # Unsalted Butter
        ("INV054", 2.0, "each"),  # Free Range Eggs
        ("INV061", 0.05, "kg"),   # Plain Flour
        ("INV053", 0.04, "L"),    # Whole Milk
    ],
    "PROD044": [  # Affogato
        ("INV111", 0.014, "kg"),  # Espresso Beans
        ("INV060", 0.06, "kg"),   # Mascarpone
        ("INV085", 0.02, "kg"),   # Caster Sugar
    ],
    "PROD045": [  # Sorbet Trio
        ("INV085", 0.05, "kg"),   # Caster Sugar
        ("INV040", 1.0, "each"),  # Apple
        ("INV041", 0.5, "each"),  # Mango
        ("INV039", 1.0, "each"),  # Lime
    ],
    "PROD046": [  # Crème Brûlée
        ("INV046", 0.12, "L"),    # Double Cream
        ("INV054", 3.0, "each"),  # Free Range Eggs
        ("INV085", 0.05, "kg"),   # Caster Sugar
        ("INV116", 0.01, "L"),    # Vanilla Syrup
    ],
    "PROD047": [  # Apple Crumble
        ("INV040", 2.0, "each"),  # Apple
        ("INV084", 0.06, "kg"),   # Brown Sugar
        ("INV061", 0.08, "kg"),   # Plain Flour
        ("INV047", 0.05, "kg"),   # Unsalted Butter
        ("INV046", 0.06, "L"),    # Double Cream
    ],
    "PROD048": [  # Cheese Board
        ("INV051", 0.05, "kg"),   # Brie
        ("INV052", 0.05, "kg"),   # Stilton
        ("INV048", 0.05, "kg"),   # Cheddar Cheese
        ("INV081", 6.0, "each"),  # Crackers
        ("INV074", 0.02, "kg"),   # Honey
    ],
    "PROD049": [  # Panna Cotta
        ("INV046", 0.15, "L"),    # Double Cream
        ("INV085", 0.04, "kg"),   # Caster Sugar
        ("INV116", 0.01, "L"),    # Vanilla Syrup
        ("INV041", 0.5, "each"),  # Mango
    ],
    # --- Soft Drinks (10) ---
    "PROD050": [  # Cola
        ("INV105", 0.035, "L"),   # Cola Syrup
    ],
    "PROD051": [  # Diet Cola
        ("INV105", 0.030, "L"),   # Cola Syrup
    ],
    "PROD052": [  # Lemonade
        ("INV106", 0.035, "L"),   # Lemonade Syrup
    ],
    "PROD053": [  # Sparkling Water
        ("INV075", 0.001, "kg"),  # Sea Salt (negligible — vessel cost proxy)
    ],
    "PROD054": [  # Still Water
        ("INV075", 0.001, "kg"),  # Sea Salt (negligible — vessel cost proxy)
    ],
    "PROD055": [  # Fresh Orange Juice
        ("INV038", 3.0, "each"),  # Lemon (orange proxy)
    ],
    "PROD056": [  # Apple Juice
        ("INV040", 2.0, "each"),  # Apple
    ],
    "PROD057": [  # Elderflower Pressé
        ("INV107", 0.03, "L"),    # Elderflower Cordial
    ],
    "PROD058": [  # Ginger Beer
        ("INV108", 1.0, "each"),  # Ginger Beer (Bottle)
    ],
    "PROD059": [  # Virgin Mojito
        ("INV088", 0.0, "L"),     # White Rum (zero — virgin)
        ("INV039", 1.0, "each"),  # Lime
        ("INV106", 0.02, "L"),    # Lemonade Syrup
        ("INV029", 0.003, "kg"),  # Fresh Basil (mint proxy)
    ],
    # --- Cocktails (10) ---
    "PROD060": [  # Espresso Martini
        ("INV086", 0.05, "L"),    # Vodka
        ("INV111", 0.014, "kg"),  # Espresso Beans
        ("INV117", 0.015, "L"),   # Caramel Syrup
        ("INV053", 0.02, "L"),    # Whole Milk (cream float)
    ],
    "PROD061": [  # Margarita
        ("INV092", 0.05, "L"),    # Tequila
        ("INV039", 1.0, "each"),  # Lime
        ("INV116", 0.02, "L"),    # Vanilla Syrup (triple sec proxy)
        ("INV075", 0.002, "kg"),  # Sea Salt
    ],
    "PROD062": [  # Old Fashioned
        ("INV090", 0.06, "L"),    # Bourbon Whiskey
        ("INV110", 0.003, "L"),   # Angostura Bitters
        ("INV084", 0.005, "kg"),  # Brown Sugar
        ("INV040", 0.5, "each"),  # Apple (garnish)
    ],
    "PROD063": [  # Aperol Spritz
        ("INV093", 0.06, "L"),    # Aperol
        ("INV096", 0.09, "L"),    # Prosecco (Bulk)
        ("INV038", 0.25, "each"), # Lemon (garnish)
    ],
    "PROD064": [  # Mojito
        ("INV088", 0.05, "L"),    # White Rum
        ("INV039", 1.0, "each"),  # Lime
        ("INV106", 0.02, "L"),    # Lemonade Syrup
        ("INV029", 0.003, "kg"),  # Fresh Basil (mint proxy)
    ],
    "PROD065": [  # Negroni
        ("INV087", 0.03, "L"),    # Gin
        ("INV094", 0.03, "L"),    # Sweet Vermouth
        ("INV095", 0.03, "L"),    # Campari
        ("INV040", 0.25, "each"), # Apple (orange peel proxy)
    ],
    "PROD066": [  # Pornstar Martini
        ("INV086", 0.05, "L"),    # Vodka
        ("INV041", 0.5, "each"),  # Mango
        ("INV116", 0.02, "L"),    # Vanilla Syrup
        ("INV096", 0.05, "L"),    # Prosecco (Bulk)
    ],
    "PROD067": [  # Piña Colada
        ("INV088", 0.05, "L"),    # White Rum
        ("INV109", 0.06, "L"),    # Coconut Cream
        ("INV041", 0.5, "each"),  # Mango (pineapple proxy)
        ("INV085", 0.01, "kg"),   # Caster Sugar
    ],
    "PROD068": [  # Whisky Sour
        ("INV091", 0.05, "L"),    # Scotch Whisky
        ("INV038", 1.0, "each"),  # Lemon
        ("INV085", 0.01, "kg"),   # Caster Sugar
        ("INV054", 1.0, "each"),  # Free Range Eggs (egg white)
    ],
    "PROD069": [  # Cosmopolitan
        ("INV086", 0.04, "L"),    # Vodka
        ("INV039", 0.5, "each"),  # Lime
        ("INV116", 0.02, "L"),    # Vanilla Syrup (triple sec proxy)
        ("INV105", 0.03, "L"),    # Cola Syrup (cranberry proxy)
    ],
    # --- Wine & Beer (11) ---
    "PROD070": [  # House Red
        ("INV097", 0.175, "L"),   # House Red Wine
    ],
    "PROD071": [  # House White
        ("INV098", 0.175, "L"),   # House White Wine
    ],
    "PROD072": [  # House Rosé
        ("INV099", 0.175, "L"),   # House Rose Wine
    ],
    "PROD073": [  # Prosecco
        ("INV096", 0.125, "L"),   # Prosecco (Bulk)
    ],
    "PROD074": [  # IPA
        ("INV100", 0.568, "L"),   # IPA Keg (1 pint)
    ],
    "PROD075": [  # Lager
        ("INV101", 0.568, "L"),   # Lager Keg (1 pint)
    ],
    "PROD076": [  # Stout
        ("INV102", 0.568, "L"),   # Stout Keg (1 pint)
    ],
    "PROD077": [  # Pale Ale
        ("INV103", 0.568, "L"),   # Pale Ale Keg (1 pint)
    ],
    "PROD078": [  # Cider
        ("INV104", 0.568, "L"),   # Cider Keg (1 pint)
    ],
    "PROD079": [  # Sauvignon Blanc
        ("INV098", 0.175, "L"),   # House White Wine (premium glass)
    ],
    "PROD080": [  # Merlot
        ("INV097", 0.175, "L"),   # House Red Wine (premium glass)
    ],
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
