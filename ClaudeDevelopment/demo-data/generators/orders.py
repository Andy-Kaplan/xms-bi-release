"""
Orders generator — produces ~55K CUSTORDERs + ~150K LINEITEMs + all POS link tables.

Output files (16 CSVs):
  hub_custorder.csv, sat_custorder.csv
  hub_lineitem.csv, sat_lineitem.csv
  lnk_custorder_location.csv
  lnk_custorder_employee.csv
  lnk_custorder_lineitem.csv
  lnk_custorder_occasion.csv
  lnk_custorder_revcenter.csv
  lnk_lineitem_product.csv
  lnk_lineitem_tax.csv
  lnk_lineitem_occasion.csv
  lnk_employee_lineitem.csv
  lnk_discount_lineitem.csv
  lnk_lineitem_lineitem.csv
  sat_lnk_lineitem_lineitem.csv

All AGG columns = 0. SRC = config.POS_SRC for all rows.
"""

import os
import sys
import random
from datetime import date, timedelta, datetime

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

import config
from hash_utils import make_hub_id, make_lnk_id
from csv_writer import DvCsvWriter
from generators.reference_data import ReferenceData
from generators.recipes import RecipeData
from generators.narratives import (
    get_order_count_multiplier,
    get_items_per_order,
    get_discount_rate,
    get_product_weight_multiplier,
    get_cocktail_weight_multiplier,
    get_burger_weight_multiplier,
    get_dessert_weight_multiplier,
    get_time_shift_hours,
)

# ── Constants ─────────────────────────────────────────────────────────────────

SRC = config.POS_SRC
IS_DELETED = 0
CURRENT_FLAG = 1
AGG_ZERO = 0

# Effective dates for all transactional data
EFFECTIVE_FROM = datetime(2025, 9, 30, 0, 0, 0)
EFFECTIVE_TO   = datetime(9999, 12, 31, 23, 59, 59)

# Pre-compute product lookup tables at module level for performance
_PRODUCTS_LIST = config.PRODUCTS
_PRODUCT_MAP = {p["id"]: p for p in _PRODUCTS_LIST}
_PRODUCT_IDS = [p["id"] for p in _PRODUCTS_LIST]

# Category sets for modifier functions
_COCKTAIL_IDS = {p["id"] for p in _PRODUCTS_LIST if p["cat"] == "CAT_COCK"}
_BURGER_IDS   = {p["id"] for p in _PRODUCTS_LIST if p["cat"] == "CAT_BURG"}
_DESSERT_IDS  = {p["id"] for p in _PRODUCTS_LIST if p["cat"] == "CAT_DESS"}

# Tax rate — all products attract 20% VAT
_DEFAULT_TAX_ID = "TAX001"  # "VAT 20%", multiplier=0.20
_TAX_RATE = 0.20

# Occasion weights
_OCC_IDS     = [o["id"] for o in config.OCCASIONS]
_OCC_WEIGHTS = [o["weight"] for o in config.OCCASIONS]

# Time distribution lists (hour list + weights list, pre-computed)
_TIME_HOURS   = sorted(config.ORDER_TIME_WEIGHTS.keys())
_TIME_WEIGHTS = [config.ORDER_TIME_WEIGHTS[h] for h in _TIME_HOURS]

# Cooccurrence pairs — pre-processed for fast lookup
# Each entry: (trigger_set: set of ids/cat_ids, boosted_set: set of prod_ids, affinity: float)
def _build_cooccurrence_rules():
    """Parse config.NARRATIVES['cooccurrence']['pairs'] into fast lookup structures."""
    cat_to_prods = {}
    for p in _PRODUCTS_LIST:
        cat_to_prods.setdefault(p["cat"], []).append(p["id"])

    rules = []
    for (trigger, boosted_list, affinity) in config.NARRATIVES["cooccurrence"]["pairs"]:
        # Expand trigger to a set of product IDs
        if trigger.startswith("CAT_"):
            trigger_ids = set(cat_to_prods.get(trigger, []))
        else:
            trigger_ids = {trigger}

        # Expand boosted list to a set of product IDs
        boosted_ids = set()
        for b in boosted_list:
            if b.startswith("CAT_"):
                boosted_ids.update(cat_to_prods.get(b, []))
            else:
                boosted_ids.add(b)

        rules.append((trigger_ids, boosted_ids, affinity))
    return rules

_COOCCURRENCE_RULES = _build_cooccurrence_rules()

# Upsell location rules: {loc_id: {cat_id: boost_weight}}
_UPSELL_RULES = config.NARRATIVES["cooccurrence"].get("upsell_location", {})
def _build_upsell_cat_prod():
    """Map upsell rules from cat → boost to prod → boost."""
    cat_to_prods = {}
    for p in _PRODUCTS_LIST:
        cat_to_prods.setdefault(p["cat"], []).append(p["id"])

    result = {}  # {loc_id: {prod_id: boost}}
    for loc_id, cat_boosts in _UPSELL_RULES.items():
        prod_boosts = {}
        for cat_id, boost in cat_boosts.items():
            for pid in cat_to_prods.get(cat_id, []):
                prod_boosts[pid] = boost
        result[loc_id] = prod_boosts
    return result

_UPSELL_PROD_MAP = _build_upsell_cat_prod()

# Modifier items: small-value child line items attached to ~17% of PROD items
_MODIFIER_ITEMS = [
    {"name": "Extra Shot",         "price": 1.00},
    {"name": "Add Bacon",          "price": 1.50},
    {"name": "Sauce on the Side",  "price": 0.50},
    {"name": "Extra Portion",      "price": 2.00},
    {"name": "Upgrade to Large",   "price": 1.50},
    {"name": "Gluten Free Option", "price": 1.00},
    {"name": "No Ice",             "price": 0.00},
    {"name": "Add Cheese",         "price": 1.00},
]
_MODIFIER_RATE = 0.17  # probability a PROD item gets a modifier child


# ── Column schemas ────────────────────────────────────────────────────────────

HUB_COLS = ["HUB_ID", "SRC", "IS_DELETED", "LOAD_TS"]

SAT_CUSTORDER_COLS = [
    "HUB_ID", "SRC", "LOAD_TS", "EFFECTIVEFROM", "EFFECTIVETO",
    "CURRENT_FLAG", "IS_DELETED",
    "GRAND_TOTAL", "GRAND_TOTAL_SRC",
    "DISCOUNT_GROSS", "DISCOUNT_GROSS_SRC",
    "SVC_CHARGE_TOTAL", "SVC_CHARGE_TOTAL_SRC",
    "GROSS_SALES", "GROSS_SALES_SRC",
    "TAX_TOTAL", "TAX_TOTAL_SRC",
    "NET_SALES", "NET_SALES_SRC",
    "GUEST_COUNT", "ITEM_COUNT", "ITEM_COUNT_SRC",
    "ORDER_COUNT",
    "OPEN_TIME", "CLOSE_TIME", "ORDER_DATE",
    "TABLE_NO", "ORDER_INFO", "EXTERNAL_REFERENCE",
    "ORDER_STATUS", "PAYMENT_STATUS",
    "DISCOUNT_NET", "DISCOUNT_NET_SRC",
    "DISCOUNT_TAX", "DISCOUNT_TAX_SRC",
    "TENDERED_SALES",
    "TRADING_DATE",
]

SAT_LINEITEM_COLS = [
    "HUB_ID", "SRC", "LOAD_TS", "EFFECTIVEFROM", "EFFECTIVETO",
    "CURRENT_FLAG", "IS_DELETED",
    "HEADER_ID", "LINEITEM_TYPE",
    "GROSS_VALUE", "TAX_VALUE", "NET_VALUE",
    "QUANTITY", "QUANTITY_INV",
    "LINEITEM_TIMESTAMP", "ITEM_DATE", "ORDER_DATE",
    "VOID_FLAG", "LINE_ID", "LINE_ORDER",
    "TRADING_DATE", "SRC_KEY",
]

LNK_BINARY_COLS = lambda a, b: ["LNK_ID", "SRC", "LOAD_TS",
                                  f"{a}_HUB_ID", f"{b}_HUB_ID",
                                  f"{a}_AGG", f"{b}_AGG"]

LNK_LINEITEM_LINEITEM_COLS = [
    "LNK_ID", "SRC", "LOAD_TS",
    "PARENT_HUB_ID", "CHILD_HUB_ID",
    "PARENT_AGG", "CHILD_AGG",
]

SAT_LNK_LINEITEM_LINEITEM_COLS = [
    "LNK_ID", "SRC", "LOAD_TS",
    "LABEL", "VALUE", "INFO",
]


# ── Product weight helpers ────────────────────────────────────────────────────

def _build_product_weights(loc_id: str, current_date: date, day_of_week: int) -> list:
    """Build base weight list for all products, incorporating narrative modifiers."""
    weights = []
    for pid in _PRODUCT_IDS:
        w = 1.0
        w *= get_product_weight_multiplier(pid, current_date)
        if pid in _COCKTAIL_IDS:
            w *= get_cocktail_weight_multiplier(loc_id, day_of_week)
        if pid in _BURGER_IDS:
            w *= get_burger_weight_multiplier(loc_id, day_of_week)
        if pid in _DESSERT_IDS:
            w *= get_dessert_weight_multiplier(loc_id, day_of_week)
        weights.append(w)
    return weights


def _apply_cooccurrence(weights: list, selected_ids: set, loc_id: str) -> list:
    """Apply cooccurrence affinity boosts based on already-selected products."""
    new_weights = list(weights)

    for (trigger_ids, boosted_ids, affinity) in _COOCCURRENCE_RULES:
        if selected_ids & trigger_ids:  # any selected product triggers this rule
            for i, pid in enumerate(_PRODUCT_IDS):
                if pid in boosted_ids:
                    new_weights[i] *= (1.0 + affinity)

    # Upsell location boost
    loc_boosts = _UPSELL_PROD_MAP.get(loc_id, {})
    for i, pid in enumerate(_PRODUCT_IDS):
        if pid in loc_boosts:
            new_weights[i] *= (1.0 + loc_boosts[pid])

    return new_weights


def _pick_time(loc_id: str, day_of_week: int, rng: random.Random) -> tuple:
    """Pick a random datetime for the order based on time-of-day weights."""
    shift = get_time_shift_hours(loc_id, day_of_week)
    hours  = [min(h + shift, 23) for h in _TIME_HOURS]
    hour   = rng.choices(hours, weights=_TIME_WEIGHTS, k=1)[0]
    minute = rng.randint(0, 59)
    second = rng.randint(0, 59)
    return hour, minute, second


def _round2(v: float) -> float:
    return round(v, 2)


# ── Main generator ────────────────────────────────────────────────────────────

def generate_orders(output_dir: str, ref: ReferenceData, recipes: RecipeData) -> dict:
    """Generate all order + line-item CSVs.

    Returns:
        sales_data: dict[date_str][loc_id][product_id] = total_quantity_sold
    """
    os.makedirs(output_dir, exist_ok=True)

    rng = random.Random(42)

    # ── Open all writers ──────────────────────────────────────────────────────
    def _path(name: str) -> str:
        return os.path.join(output_dir, name)

    hub_co    = DvCsvWriter(_path("hub_custorder.csv"),    HUB_COLS)
    sat_co    = DvCsvWriter(_path("sat_custorder.csv"),    SAT_CUSTORDER_COLS)
    hub_li    = DvCsvWriter(_path("hub_lineitem.csv"),     HUB_COLS)
    sat_li    = DvCsvWriter(_path("sat_lineitem.csv"),     SAT_LINEITEM_COLS)

    lnk_co_loc  = DvCsvWriter(_path("lnk_custorder_location.csv"),
                               LNK_BINARY_COLS("CUSTORDER", "LOCATION"))
    lnk_co_emp  = DvCsvWriter(_path("lnk_custorder_employee.csv"),
                               LNK_BINARY_COLS("CUSTORDER", "EMPLOYEE"))
    lnk_co_li   = DvCsvWriter(_path("lnk_custorder_lineitem.csv"),
                               LNK_BINARY_COLS("CUSTORDER", "LINEITEM"))
    lnk_co_occ  = DvCsvWriter(_path("lnk_custorder_occasion.csv"),
                               LNK_BINARY_COLS("CUSTORDER", "OCCASION"))
    lnk_co_rc   = DvCsvWriter(_path("lnk_custorder_revcenter.csv"),
                               LNK_BINARY_COLS("CUSTORDER", "REVCENTER"))

    lnk_li_prod = DvCsvWriter(_path("lnk_lineitem_product.csv"),
                               LNK_BINARY_COLS("LINEITEM", "PRODUCT"))
    lnk_li_tax  = DvCsvWriter(_path("lnk_lineitem_tax.csv"),
                               LNK_BINARY_COLS("LINEITEM", "TAX"))
    lnk_li_occ  = DvCsvWriter(_path("lnk_lineitem_occasion.csv"),
                               LNK_BINARY_COLS("LINEITEM", "OCCASION"))
    lnk_emp_li  = DvCsvWriter(_path("lnk_employee_lineitem.csv"),
                               LNK_BINARY_COLS("EMPLOYEE", "LINEITEM"))
    lnk_disc_li = DvCsvWriter(_path("lnk_discount_lineitem.csv"),
                               LNK_BINARY_COLS("DISCOUNT", "LINEITEM"))

    lnk_lili    = DvCsvWriter(_path("lnk_lineitem_lineitem.csv"),
                               LNK_LINEITEM_LINEITEM_COLS)
    sat_lili    = DvCsvWriter(_path("sat_lnk_lineitem_lineitem.csv"),
                               SAT_LNK_LINEITEM_LINEITEM_COLS)

    # ── Counters for business keys ────────────────────────────────────────────
    order_counter    = 1
    lineitem_counter = 1

    # ── Pre-compute fixed hub IDs for entities used per order ─────────────────
    # Default tax hub ID
    tax_hub_id = ref.taxes[_DEFAULT_TAX_ID]

    # ── Sales accumulator ─────────────────────────────────────────────────────
    # sales_data[date_str][loc_id][product_id] = total_qty_sold
    sales_data: dict = {}

    # ── Date loop ─────────────────────────────────────────────────────────────
    total_days = (config.END_DATE - config.START_DATE).days + 1

    for day_offset in range(total_days):
        current_date = config.START_DATE + timedelta(days=day_offset)
        day_of_week  = current_date.weekday()
        date_str     = current_date.isoformat()

        if date_str not in sales_data:
            sales_data[date_str] = {}

        for location in config.LOCATIONS:
            loc_id = location["id"]

            if loc_id not in sales_data[date_str]:
                sales_data[date_str][loc_id] = {}

            # Hub IDs for this location
            loc_hub_id = ref.locations[loc_id]
            rc_id      = f"RC_{loc_id}"
            rc_hub_id  = ref.revcenters[rc_id]

            # Determine order count for this day/location
            base_count   = config.AVG_ORDERS_PER_DAY_PER_LOCATION
            multiplier   = get_order_count_multiplier(loc_id, current_date, day_of_week)
            order_count  = max(1, int(base_count * multiplier + rng.gauss(0, 3)))

            # Build base product weights for this day/location
            base_weights = _build_product_weights(loc_id, current_date, day_of_week)

            # Discount rate for this location/day
            disc_rate = get_discount_rate(loc_id, current_date)

            # Employee list for this location
            emp_ids = ref.location_employees[loc_id]

            for _ in range(order_count):
                # ── Pick order attributes ──────────────────────────────────
                hour, minute, second = _pick_time(loc_id, day_of_week, rng)
                order_ts = datetime(
                    current_date.year, current_date.month, current_date.day,
                    hour, minute, second
                )
                close_ts = datetime(
                    current_date.year, current_date.month, current_date.day,
                    min(hour + 1, 23), rng.randint(0, 59), rng.randint(0, 59)
                )

                emp_id      = rng.choice(emp_ids)
                emp_hub_id  = ref.employees[emp_id]

                occ_id      = rng.choices(_OCC_IDS, weights=_OCC_WEIGHTS, k=1)[0]
                occ_hub_id  = ref.occasions[occ_id]

                table_no    = rng.randint(1, 20)
                guest_count = rng.randint(1, 4)

                # Order business key and hub ID
                ord_bk      = f"ORD{order_counter:08d}"
                order_counter += 1
                ord_hub_id  = make_hub_id(ord_bk, SRC)
                load_ts     = order_ts  # treat order time as load timestamp

                # ── Determine product line items ───────────────────────────
                avg_items   = get_items_per_order(loc_id, current_date)
                item_count  = max(1, int(rng.gauss(avg_items, 1.0)))

                # Accumulators for order-level totals
                gross_sales      = 0.0
                tax_total        = 0.0
                discount_gross   = 0.0

                # Line item data to write after we have order hub ID
                order_lineitems = []  # list of dicts with all lineitem data

                selected_ids = set()  # product IDs chosen so far (for cooccurrence)

                line_order = 1  # position within the order

                for item_idx in range(item_count):
                    # Apply cooccurrence boosts after first product
                    if item_idx == 0:
                        weights = base_weights
                    else:
                        weights = _apply_cooccurrence(base_weights, selected_ids, loc_id)

                    prod_id  = rng.choices(_PRODUCT_IDS, weights=weights, k=1)[0]
                    prod     = _PRODUCT_MAP[prod_id]
                    quantity = 1
                    price    = prod["price"]

                    selected_ids.add(prod_id)
                    prod_hub_id = ref.products[prod_id]

                    gross_v = _round2(price * quantity)
                    tax_v   = _round2(gross_v * _TAX_RATE)
                    net_v   = _round2(gross_v - tax_v)

                    li_bk       = f"LI{lineitem_counter:08d}"
                    lineitem_counter += 1
                    li_hub_id   = make_hub_id(li_bk, SRC)

                    order_lineitems.append({
                        "hub_id":   li_hub_id,
                        "bk":       li_bk,
                        "type":     "PROD",
                        "gross_v":  gross_v,
                        "tax_v":    tax_v,
                        "net_v":    net_v,
                        "qty":      quantity,
                        "prod_id":  prod_id,
                        "prod_hub_id": prod_hub_id,
                        "line_order": line_order,
                        "parent_hub_id": None,
                    })
                    line_order += 1

                    gross_sales += gross_v
                    tax_total   += tax_v

                    # Track sales for inventory generator
                    sales_data[date_str][loc_id][prod_id] = (
                        sales_data[date_str][loc_id].get(prod_id, 0.0) + quantity
                    )

                    # ── Modifier child item (17% of PROD items) ───────────
                    if rng.random() < _MODIFIER_RATE:
                        mod = rng.choice(_MODIFIER_ITEMS)
                        mod_price = mod["price"]
                        mod_gross = _round2(mod_price)
                        mod_tax   = _round2(mod_gross * _TAX_RATE)
                        mod_net   = _round2(mod_gross - mod_tax)

                        mod_bk     = f"LI{lineitem_counter:08d}"
                        lineitem_counter += 1
                        mod_hub_id = make_hub_id(mod_bk, SRC)

                        order_lineitems.append({
                            "hub_id":        mod_hub_id,
                            "bk":            mod_bk,
                            "type":          "MOD",
                            "gross_v":       mod_gross,
                            "tax_v":         mod_tax,
                            "net_v":         mod_net,
                            "qty":           1,
                            "prod_id":       None,
                            "prod_hub_id":   None,
                            "line_order":    line_order,
                            "parent_hub_id": li_hub_id,
                            "mod_label":     mod["name"],
                        })
                        line_order += 1

                        gross_sales += mod_gross
                        tax_total   += mod_tax

                # ── Discount line item ─────────────────────────────────────
                discount_hub_id = None
                disc_id = None
                if rng.random() < disc_rate and gross_sales > 0:
                    disc_entry = rng.choice(config.DISCOUNTS)
                    disc_id    = disc_entry["id"]
                    disc_hub_id = ref.discounts[disc_id]

                    if disc_entry["value_type"] == "PERCENT":
                        disc_amount = _round2(gross_sales * disc_entry["value"] / 100.0)
                    else:  # FIXED
                        disc_amount = min(_round2(disc_entry["value"]), gross_sales)

                    disc_gross = _round2(-disc_amount)
                    disc_tax   = _round2(disc_gross * _TAX_RATE)
                    disc_net   = _round2(disc_gross - disc_tax)

                    discount_gross = disc_gross  # negative value

                    disc_bk     = f"LI{lineitem_counter:08d}"
                    lineitem_counter += 1
                    disc_hub_id_li = make_hub_id(disc_bk, SRC)

                    order_lineitems.append({
                        "hub_id":       disc_hub_id_li,
                        "bk":           disc_bk,
                        "type":         "DISCOUNT",
                        "gross_v":      disc_gross,
                        "tax_v":        disc_tax,
                        "net_v":        disc_net,
                        "qty":          1,
                        "prod_id":      None,
                        "prod_hub_id":  None,
                        "line_order":   line_order,
                        "parent_hub_id": None,
                        "disc_id":      disc_id,
                        "disc_hub_id":  disc_hub_id,
                    })
                    line_order += 1

                # ── Compute order totals ───────────────────────────────────
                gross_sales  = _round2(gross_sales)
                tax_total    = _round2(tax_total)
                net_sales    = _round2(gross_sales - tax_total)
                grand_total  = _round2(gross_sales + discount_gross)
                discount_net = _round2(discount_gross / (1.0 + _TAX_RATE)) if discount_gross else 0.0
                discount_tax = _round2(discount_gross - discount_net) if discount_gross else 0.0

                prod_count   = sum(1 for li in order_lineitems if li["type"] == "PROD")

                # ── Write hub_custorder ────────────────────────────────────
                hub_co.writerow([ord_hub_id, SRC, IS_DELETED, load_ts])

                # ── Write sat_custorder ────────────────────────────────────
                trading_date = current_date
                sat_co.writerow([
                    ord_hub_id, SRC, load_ts, EFFECTIVE_FROM, EFFECTIVE_TO,
                    CURRENT_FLAG, IS_DELETED,
                    grand_total,    grand_total,      # GRAND_TOTAL + _SRC (post-discount total)
                    discount_gross, discount_gross,   # DISCOUNT_GROSS + _SRC
                    0.0,            0.0,              # SVC_CHARGE_TOTAL + _SRC
                    gross_sales,    gross_sales,      # GROSS_SALES + _SRC
                    tax_total,      tax_total,        # TAX_TOTAL + _SRC
                    net_sales,      net_sales,        # NET_SALES + _SRC
                    guest_count,
                    prod_count,     prod_count,       # ITEM_COUNT + _SRC
                    1,                                # ORDER_COUNT
                    order_ts,       close_ts,         # OPEN_TIME, CLOSE_TIME
                    current_date,                     # ORDER_DATE
                    str(table_no),                    # TABLE_NO
                    None,                             # ORDER_INFO
                    ord_bk,                           # EXTERNAL_REFERENCE
                    "CLOSED",                         # ORDER_STATUS
                    "PAID",                           # PAYMENT_STATUS
                    discount_net,   discount_net,     # DISCOUNT_NET + _SRC
                    discount_tax,   discount_tax,     # DISCOUNT_TAX + _SRC
                    grand_total,                      # TENDERED_SALES
                    trading_date,                     # TRADING_DATE
                ])

                # ── Write order-level links ────────────────────────────────
                # lnk_custorder_location
                lnk_id = make_lnk_id(ord_hub_id, loc_hub_id, src=SRC)
                lnk_co_loc.writerow([lnk_id, SRC, load_ts,
                                     ord_hub_id, loc_hub_id, AGG_ZERO, AGG_ZERO])

                # lnk_custorder_employee
                lnk_id = make_lnk_id(ord_hub_id, emp_hub_id, src=SRC)
                lnk_co_emp.writerow([lnk_id, SRC, load_ts,
                                     ord_hub_id, emp_hub_id, AGG_ZERO, AGG_ZERO])

                # lnk_custorder_occasion
                lnk_id = make_lnk_id(ord_hub_id, occ_hub_id, src=SRC)
                lnk_co_occ.writerow([lnk_id, SRC, load_ts,
                                     ord_hub_id, occ_hub_id, AGG_ZERO, AGG_ZERO])

                # lnk_custorder_revcenter
                lnk_id = make_lnk_id(ord_hub_id, rc_hub_id, src=SRC)
                lnk_co_rc.writerow([lnk_id, SRC, load_ts,
                                    ord_hub_id, rc_hub_id, AGG_ZERO, AGG_ZERO])

                # ── Write line items ───────────────────────────────────────
                for li in order_lineitems:
                    li_hub_id  = li["hub_id"]
                    li_bk      = li["bk"]
                    li_type    = li["type"]
                    li_gross   = li["gross_v"]
                    li_tax     = li["tax_v"]
                    li_net     = li["net_v"]
                    li_qty     = li["qty"]

                    # hub_lineitem
                    hub_li.writerow([li_hub_id, SRC, IS_DELETED, load_ts])

                    # sat_lineitem
                    sat_li.writerow([
                        li_hub_id, SRC, load_ts, EFFECTIVE_FROM, EFFECTIVE_TO,
                        CURRENT_FLAG, IS_DELETED,
                        ord_bk,      # HEADER_ID
                        li_type,     # LINEITEM_TYPE
                        li_gross,    # GROSS_VALUE
                        li_tax,      # TAX_VALUE
                        li_net,      # NET_VALUE
                        li_qty,      # QUANTITY
                        li_qty,      # QUANTITY_INV
                        order_ts,    # LINEITEM_TIMESTAMP
                        current_date, # ITEM_DATE
                        current_date, # ORDER_DATE
                        0,           # VOID_FLAG
                        li_bk,       # LINE_ID
                        li["line_order"],  # LINE_ORDER
                        current_date, # TRADING_DATE
                        li_bk,       # SRC_KEY
                    ])

                    # lnk_custorder_lineitem (all line items)
                    lnk_id = make_lnk_id(ord_hub_id, li_hub_id, src=SRC)
                    lnk_co_li.writerow([lnk_id, SRC, load_ts,
                                        ord_hub_id, li_hub_id, AGG_ZERO, AGG_ZERO])

                    # lnk_lineitem_occasion (all items)
                    lnk_id = make_lnk_id(li_hub_id, occ_hub_id, src=SRC)
                    lnk_li_occ.writerow([lnk_id, SRC, load_ts,
                                         li_hub_id, occ_hub_id, AGG_ZERO, AGG_ZERO])

                    # lnk_employee_lineitem (all items)
                    lnk_id = make_lnk_id(emp_hub_id, li_hub_id, src=SRC)
                    lnk_emp_li.writerow([lnk_id, SRC, load_ts,
                                         emp_hub_id, li_hub_id, AGG_ZERO, AGG_ZERO])

                    # Type-specific links
                    if li_type == "PROD":
                        prod_hub_id = li["prod_hub_id"]

                        # lnk_lineitem_product
                        lnk_id = make_lnk_id(li_hub_id, prod_hub_id, src=SRC)
                        lnk_li_prod.writerow([lnk_id, SRC, load_ts,
                                              li_hub_id, prod_hub_id, AGG_ZERO, AGG_ZERO])

                        # lnk_lineitem_tax (one TAX line per PROD line)
                        # Create a paired TAX lineitem
                        tax_li_bk     = f"LI{lineitem_counter:08d}"
                        lineitem_counter += 1
                        tax_li_hub_id = make_hub_id(tax_li_bk, SRC)

                        hub_li.writerow([tax_li_hub_id, SRC, IS_DELETED, load_ts])
                        sat_li.writerow([
                            tax_li_hub_id, SRC, load_ts, EFFECTIVE_FROM, EFFECTIVE_TO,
                            CURRENT_FLAG, IS_DELETED,
                            ord_bk,         # HEADER_ID
                            "TAX",          # LINEITEM_TYPE
                            li_gross,       # GROSS_VALUE (same as PROD)
                            li_tax,         # TAX_VALUE
                            li_net,         # NET_VALUE
                            li_qty,         # QUANTITY
                            li_qty,         # QUANTITY_INV
                            order_ts,       # LINEITEM_TIMESTAMP
                            current_date,   # ITEM_DATE
                            current_date,   # ORDER_DATE
                            0,              # VOID_FLAG
                            tax_li_bk,      # LINE_ID
                            li["line_order"],  # LINE_ORDER (same as PROD)
                            current_date,   # TRADING_DATE
                            tax_li_bk,      # SRC_KEY
                        ])

                        # lnk_custorder_lineitem for TAX item too
                        lnk_id = make_lnk_id(ord_hub_id, tax_li_hub_id, src=SRC)
                        lnk_co_li.writerow([lnk_id, SRC, load_ts,
                                            ord_hub_id, tax_li_hub_id, AGG_ZERO, AGG_ZERO])

                        # lnk_lineitem_occasion for TAX item
                        lnk_id = make_lnk_id(tax_li_hub_id, occ_hub_id, src=SRC)
                        lnk_li_occ.writerow([lnk_id, SRC, load_ts,
                                             tax_li_hub_id, occ_hub_id, AGG_ZERO, AGG_ZERO])

                        # lnk_employee_lineitem for TAX item
                        lnk_id = make_lnk_id(emp_hub_id, tax_li_hub_id, src=SRC)
                        lnk_emp_li.writerow([lnk_id, SRC, load_ts,
                                             emp_hub_id, tax_li_hub_id, AGG_ZERO, AGG_ZERO])

                        # lnk_lineitem_tax: PROD item → TAX entity
                        lnk_id = make_lnk_id(li_hub_id, tax_hub_id, src=SRC)
                        lnk_li_tax.writerow([lnk_id, SRC, load_ts,
                                             li_hub_id, tax_hub_id, AGG_ZERO, AGG_ZERO])

                    elif li_type == "DISCOUNT":
                        # lnk_discount_lineitem
                        disc_hub_id_ref = li["disc_hub_id"]
                        lnk_id = make_lnk_id(disc_hub_id_ref, li_hub_id, src=SRC)
                        lnk_disc_li.writerow([lnk_id, SRC, load_ts,
                                              disc_hub_id_ref, li_hub_id, AGG_ZERO, AGG_ZERO])

                    elif li_type == "MOD":
                        # lnk_lineitem_lineitem: parent PROD → child MOD
                        parent_hub_id = li["parent_hub_id"]
                        lnk_id = make_lnk_id(parent_hub_id, li_hub_id, src=SRC)
                        lnk_lili.writerow([lnk_id, SRC, load_ts,
                                           parent_hub_id, li_hub_id, AGG_ZERO, AGG_ZERO])
                        sat_lili.writerow([
                            lnk_id, SRC, load_ts,
                            li.get("mod_label", "Modifier"),  # LABEL
                            str(li_gross),                    # VALUE
                            None,                             # INFO
                        ])

    # ── Close all writers ──────────────────────────────────────────────────────
    hub_co.close()
    sat_co.close()
    hub_li.close()
    sat_li.close()
    lnk_co_loc.close()
    lnk_co_emp.close()
    lnk_co_li.close()
    lnk_co_occ.close()
    lnk_co_rc.close()
    lnk_li_prod.close()
    lnk_li_tax.close()
    lnk_li_occ.close()
    lnk_emp_li.close()
    lnk_disc_li.close()
    lnk_lili.close()
    sat_lili.close()

    print(f"  hub_custorder:          {hub_co.row_count:,} rows")
    print(f"  hub_lineitem:           {hub_li.row_count:,} rows")
    print(f"  lnk_custorder_lineitem: {lnk_co_li.row_count:,} rows")

    return sales_data
