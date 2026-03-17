"""
Recipe relationship link + satellite generator.

Generates 8 CSV files representing the recipe graph in the Data Vault:

  LNK_INVITEM_INVITEM                  — parent (product-as-invitem) → child (ingredient)
  SAT_LNK_INVITEM_INVITEM              — UOM + UOM_VALUE per ingredient; 3 rows for the
                                         margin-squeeze ingredient (INV001 / PROD011)
  LNK_INVITEM_OCCASION_PRODUCT         — ternary: invitem × occasion × product
  SAT_LNK_INVITEM_OCCASION_PRODUCT     — UOM + UOM_VALUE
  LNK_LOCATION_OCCASION_PRODUCT        — location × occasion × product
  SAT_LNK_LOCATION_OCCASION_PRODUCT    — NET_PRICE, NET_COST, PRODUCT_ID
  LNK_INVITEM_LOCATION_OCCASION_PRODUCT — 4-way link
  SAT_LNK_INVITEM_LOCATION_OCCASION_PRODUCT — UOM + UOM_VALUE

All links use SRC = config.INVENTORY_SRC ("int_marketman001").

Product-as-invitem entries are generated inside this module by hashing each
product_id against INVENTORY_SRC — they land in hub_invitem.csv / sat_invitem.csv
as extra rows appended during the recipe generation pass.

Return value
------------
RecipeData(
    product_ingredients: dict[prod_id → [(invitem_id, qty, uom), ...]],
    product_invitem_hub_ids: dict[prod_id → invitem_hub_id (bytes)],
)
"""
import os
import sys
from dataclasses import dataclass
from datetime import datetime

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
import config
from hash_utils import make_hub_id, make_lnk_id, to_hex
from csv_writer import DvCsvWriter
from generators.reference_data import ReferenceData

# ── Constants ────────────────────────────────────────────────────────────────

SRC = config.INVENTORY_SRC

# Single load timestamp for most recipe rows (system inception)
LOAD_TS = datetime(2025, 9, 30, 0, 0, 0)

# Margin-squeeze history timestamps for INV001 linked to PROD011
MS_TS_BASE  = datetime(2025, 10,  1, 0, 0, 0)  # Oct 1 — base cost
MS_TS_HIKE1 = datetime(2025, 12,  1, 0, 0, 0)  # Dec 1 — +15%
MS_TS_HIKE2 = datetime(2026,  2, 15, 0, 0, 0)  # Feb 15 — additional +12%

# AGG column value for binary links
AGG_ZERO = 0

# Occasion used for recipe links — "Dine-In" (first occasion in config)
DEFAULT_OCCASION_ID = config.OCCASIONS[0]["id"]  # "OCC001"


# ── Dataclass ────────────────────────────────────────────────────────────────

@dataclass
class RecipeData:
    product_ingredients: dict   # prod_id → [(invitem_id, qty, uom), ...]
    product_invitem_hub_ids: dict  # prod_id → invitem_hub_id bytes


# ── Helpers ──────────────────────────────────────────────────────────────────

def _product_invitem_id(prod_id: str) -> str:
    """Business key for the product-as-invitem entry.
    We prefix with 'PINV_' to avoid collision with real INV* keys."""
    return f"PINV_{prod_id}"


def _compute_net_cost(prod_id: str, invitem_cost_map: dict) -> float:
    """Sum ingredient costs for a product from the RECIPES config.
    invitem_cost_map: {invitem_id: cost_per_uom}  (native uom).
    Returns total recipe cost for one serving."""
    total = 0.0
    for inv_id, qty, _uom in config.RECIPES.get(prod_id, []):
        cost_per_unit = invitem_cost_map.get(inv_id, 0.0)
        total += cost_per_unit * qty
    return total


# ── Hub / Sat helpers for product-as-invitem entries ─────────────────────────

def _append_product_invitems(output_dir: str, product_ids: list[str]) -> dict:
    """Append product-as-invitem rows to hub_invitem.csv + sat_invitem.csv.
    Returns {prod_id: hub_id bytes}."""
    hub_path = os.path.join(output_dir, "hub_invitem.csv")
    sat_path = os.path.join(output_dir, "sat_invitem.csv")

    EFFECTIVE_FROM = datetime(2025, 9, 30, 0, 0, 0)
    EFFECTIVE_TO   = datetime(9999, 12, 31, 23, 59, 59)

    # Build product lookup for names
    prod_lookup = {p["id"]: p for p in config.PRODUCTS}

    ids = {}

    # Append to existing files (no header — already written by reference_data)
    with open(hub_path, "a", encoding="utf-8-sig", newline="") as hub_f, \
         open(sat_path, "a", encoding="utf-8-sig", newline="") as sat_f:

        for prod_id in product_ids:
            bk = _product_invitem_id(prod_id)
            hub_id = make_hub_id(bk, SRC)
            ids[prod_id] = hub_id

            # hub row
            hub_f.write(f"{to_hex(hub_id)}|{SRC}|0|"
                        f"{LOAD_TS.strftime('%Y-%m-%dT%H:%M:%S.')+'0000000'}\n")

            # sat row — mirrors sat_invitem schema:
            # HUB_ID|SRC|LOAD_TS|EFFECTIVEFROM|EFFECTIVETO|CURRENT_FLAG|IS_DELETED|
            # INVITEM_NAME|PARENT_ID|LEVEL_NAME|BOTTOM_LEVEL|
            # ATTR_1|ATTR_2|ATTR_3|ATTR_4|ATTR_5|
            # UOM|                   ← extra column inserted before INVITEM_ID block
            # INVITEM_ID|MICROSERVICE_ID|MICROSERVICE_NAME|MICROSERVICE_ID_BIN
            prod = prod_lookup[prod_id]
            prod_name = prod["name"]
            uom = ""  # finished products have no single UOM

            def _fmt_ts(dt: datetime) -> str:
                return dt.strftime("%Y-%m-%dT%H:%M:%S.") + "0000000"

            row = "|".join([
                to_hex(hub_id),
                SRC,
                _fmt_ts(LOAD_TS),
                _fmt_ts(EFFECTIVE_FROM),
                _fmt_ts(EFFECTIVE_TO),
                "1",          # CURRENT_FLAG
                "0",          # IS_DELETED
                prod_name,    # INVITEM_NAME
                "INVCAT_PROT",  # PARENT_ID — closest proxy; finished goods in protein cat
                "BOTTOM",     # LEVEL_NAME
                "1",          # BOTTOM_LEVEL
                "",           # ATTR_1
                "",           # ATTR_2
                "",           # ATTR_3
                "",           # ATTR_4
                "",           # ATTR_5
                uom,          # UOM
                bk,           # INVITEM_ID
                bk,           # MICROSERVICE_ID
                prod_name,    # MICROSERVICE_NAME
                to_hex(hub_id),  # MICROSERVICE_ID_BIN
            ])
            sat_f.write(row + "\n")

    return ids


# ── LNK_INVITEM_INVITEM + SAT ─────────────────────────────────────────────────

def _gen_lnk_invitem_invitem(
        output_dir: str,
        product_invitem_ids: dict,
        ref: ReferenceData,
) -> None:
    """Write lnk_invitem_invitem.csv + sat_lnk_invitem_invitem.csv."""

    lnk_path = os.path.join(output_dir, "lnk_invitem_invitem.csv")
    sat_path = os.path.join(output_dir, "sat_lnk_invitem_invitem.csv")

    lnk_cols = ["LNK_ID", "SRC", "LOAD_TS", "PARENT_HUB_ID", "CHILD_HUB_ID",
                "PARENT_AGG", "CHILD_AGG"]
    sat_cols = ["LNK_ID", "SRC", "LOAD_TS", "UOM", "UOM_VALUE"]

    # Margin-squeeze config
    ms_cfg = config.NARRATIVES["margin_squeeze"]
    ms_prod_id  = ms_cfg["product_id"]    # "PROD011"
    ms_inv_id   = ms_cfg["ingredient_id"] # "INV001"
    ms_base     = ms_cfg["base_cost_per_kg"]
    ms_hike1    = ms_base * (1.0 + ms_cfg["hike_1_pct"])
    ms_hike2    = ms_hike1 * (1.0 + ms_cfg["hike_2_pct"])

    def _fmt_ts(dt: datetime) -> str:
        return dt.strftime("%Y-%m-%dT%H:%M:%S.") + "0000000"

    with DvCsvWriter(lnk_path, lnk_cols) as lnk, \
         DvCsvWriter(sat_path, sat_cols) as sat:

        for prod_id, ingredients in config.RECIPES.items():
            parent_hub_id = product_invitem_ids.get(prod_id)
            if parent_hub_id is None:
                continue

            for (inv_id, qty, uom) in ingredients:
                child_hub_id = ref.invitems.get(inv_id)
                if child_hub_id is None:
                    continue

                lnk_id = make_lnk_id(parent_hub_id, child_hub_id, src=SRC)

                lnk.writerow([lnk_id, SRC, LOAD_TS, parent_hub_id, child_hub_id,
                               AGG_ZERO, AGG_ZERO])

                # Margin-squeeze: INV001 in PROD011 gets 3 cost-history rows
                if prod_id == ms_prod_id and inv_id == ms_inv_id:
                    sat.writerow([lnk_id, SRC, MS_TS_BASE,  uom, ms_base])
                    sat.writerow([lnk_id, SRC, MS_TS_HIKE1, uom, ms_hike1])
                    sat.writerow([lnk_id, SRC, MS_TS_HIKE2, uom, ms_hike2])
                else:
                    sat.writerow([lnk_id, SRC, LOAD_TS, uom, qty])


# ── LNK_INVITEM_OCCASION_PRODUCT + SAT ───────────────────────────────────────

def _gen_lnk_invitem_occasion_product(
        output_dir: str,
        product_invitem_ids: dict,
        ref: ReferenceData,
) -> None:
    """Write lnk_invitem_occasion_product.csv + sat_lnk_invitem_occasion_product.csv."""

    lnk_path = os.path.join(output_dir, "lnk_invitem_occasion_product.csv")
    sat_path = os.path.join(output_dir, "sat_lnk_invitem_occasion_product.csv")

    lnk_cols = ["LNK_ID", "SRC", "LOAD_TS",
                "INVITEM_HUB_ID", "OCCASION_HUB_ID", "PRODUCT_HUB_ID"]
    sat_cols = ["LNK_ID", "SRC", "LOAD_TS", "UOM", "UOM_VALUE"]

    occ_hub_id = ref.occasions[DEFAULT_OCCASION_ID]

    with DvCsvWriter(lnk_path, lnk_cols) as lnk, \
         DvCsvWriter(sat_path, sat_cols) as sat:

        for prod_id, ingredients in config.RECIPES.items():
            prod_hub_id = ref.products.get(prod_id)
            if prod_hub_id is None:
                continue

            for (inv_id, qty, uom) in ingredients:
                inv_hub_id = ref.invitems.get(inv_id)
                if inv_hub_id is None:
                    continue

                lnk_id = make_lnk_id(inv_hub_id, occ_hub_id, prod_hub_id, src=SRC)

                lnk.writerow([lnk_id, SRC, LOAD_TS,
                              inv_hub_id, occ_hub_id, prod_hub_id])
                sat.writerow([lnk_id, SRC, LOAD_TS, uom, qty])


# ── LNK_LOCATION_OCCASION_PRODUCT + SAT ──────────────────────────────────────

def _gen_lnk_location_occasion_product(
        output_dir: str,
        ref: ReferenceData,
        invitem_cost_map: dict,
) -> None:
    """Write lnk_location_occasion_product.csv + sat_lnk_location_occasion_product.csv.
    One row per location × occasion × product (~480 rows for 6 × 1 × 80)."""

    lnk_path = os.path.join(output_dir, "lnk_location_occasion_product.csv")
    sat_path = os.path.join(output_dir, "sat_lnk_location_occasion_product.csv")

    lnk_cols = ["LNK_ID", "SRC", "LOAD_TS",
                "LOCATION_HUB_ID", "OCCASION_HUB_ID", "PRODUCT_HUB_ID"]
    sat_cols = ["LNK_ID", "SRC", "LOAD_TS", "NET_PRICE", "NET_COST", "PRODUCT_ID"]

    occ_hub_id = ref.occasions[DEFAULT_OCCASION_ID]

    # Pre-compute net cost per product
    prod_net_cost = {
        p["id"]: _compute_net_cost(p["id"], invitem_cost_map)
        for p in config.PRODUCTS
    }

    prod_price = {p["id"]: p["price"] for p in config.PRODUCTS}

    with DvCsvWriter(lnk_path, lnk_cols) as lnk, \
         DvCsvWriter(sat_path, sat_cols) as sat:

        for loc in config.LOCATIONS:
            loc_hub_id = ref.locations[loc["id"]]

            for prod in config.PRODUCTS:
                prod_id = prod["id"]
                prod_hub_id = ref.products[prod_id]

                lnk_id = make_lnk_id(loc_hub_id, occ_hub_id, prod_hub_id, src=SRC)

                lnk.writerow([lnk_id, SRC, LOAD_TS,
                              loc_hub_id, occ_hub_id, prod_hub_id])
                sat.writerow([
                    lnk_id, SRC, LOAD_TS,
                    prod_price[prod_id],
                    prod_net_cost[prod_id],
                    prod_id,
                ])


# ── LNK_INVITEM_LOCATION_OCCASION_PRODUCT + SAT ──────────────────────────────

def _gen_lnk_invitem_location_occasion_product(
        output_dir: str,
        ref: ReferenceData,
) -> None:
    """Write lnk_invitem_location_occasion_product.csv +
    sat_lnk_invitem_location_occasion_product.csv.
    One row per ingredient × location × occasion × product."""

    lnk_path = os.path.join(output_dir, "lnk_invitem_location_occasion_product.csv")
    sat_path  = os.path.join(output_dir, "sat_lnk_invitem_location_occasion_product.csv")

    lnk_cols = ["LNK_ID", "SRC", "LOAD_TS",
                "INVITEM_HUB_ID", "LOCATION_HUB_ID", "OCCASION_HUB_ID", "PRODUCT_HUB_ID"]
    sat_cols = ["LNK_ID", "SRC", "LOAD_TS", "UOM", "UOM_VALUE"]

    occ_hub_id = ref.occasions[DEFAULT_OCCASION_ID]

    with DvCsvWriter(lnk_path, lnk_cols) as lnk, \
         DvCsvWriter(sat_path, sat_cols) as sat:

        for loc in config.LOCATIONS:
            loc_hub_id = ref.locations[loc["id"]]

            for prod_id, ingredients in config.RECIPES.items():
                prod_hub_id = ref.products.get(prod_id)
                if prod_hub_id is None:
                    continue

                for (inv_id, qty, uom) in ingredients:
                    inv_hub_id = ref.invitems.get(inv_id)
                    if inv_hub_id is None:
                        continue

                    lnk_id = make_lnk_id(
                        inv_hub_id, loc_hub_id, occ_hub_id, prod_hub_id,
                        src=SRC
                    )

                    lnk.writerow([lnk_id, SRC, LOAD_TS,
                                  inv_hub_id, loc_hub_id, occ_hub_id, prod_hub_id])
                    sat.writerow([lnk_id, SRC, LOAD_TS, uom, qty])


# ── Public entry point ────────────────────────────────────────────────────────

def generate_recipes(output_dir: str, ref: ReferenceData) -> RecipeData:
    """Generate all recipe link/satellite CSVs.

    Also appends product-as-invitem rows into the existing hub_invitem.csv
    and sat_invitem.csv files (which must already exist from generate_reference_data).

    Returns RecipeData with recipe ingredient lookups and product-as-invitem hub IDs.
    """
    os.makedirs(output_dir, exist_ok=True)

    # Build invitem cost map: invitem_id → cost (per native uom)
    invitem_cost_map = {item["id"]: item["cost"] for item in config.INVITEMS}

    # Product IDs that have recipes
    product_ids_with_recipes = list(config.RECIPES.keys())

    # Step 1: Add product-as-invitem hub + sat rows
    product_invitem_ids = _append_product_invitems(output_dir, product_ids_with_recipes)

    # Step 2: LNK_INVITEM_INVITEM + SAT (self-ref: product-as-invitem → ingredient)
    _gen_lnk_invitem_invitem(output_dir, product_invitem_ids, ref)

    # Step 3: LNK_INVITEM_OCCASION_PRODUCT + SAT (ternary)
    _gen_lnk_invitem_occasion_product(output_dir, product_invitem_ids, ref)

    # Step 4: LNK_LOCATION_OCCASION_PRODUCT + SAT
    _gen_lnk_location_occasion_product(output_dir, ref, invitem_cost_map)

    # Step 5: LNK_INVITEM_LOCATION_OCCASION_PRODUCT + SAT (4-way)
    _gen_lnk_invitem_location_occasion_product(output_dir, ref)

    return RecipeData(
        product_ingredients=dict(config.RECIPES),
        product_invitem_hub_ids=product_invitem_ids,
    )
