"""
Reference data generator — produces hub + sat CSVs for all 14 entity types.

Entities generated here:
  Hierarchy (9): LOCATION, PRODUCT, INVITEM, SUPPLIER, OCCASION, TENDER, TAX, REVCENTER, DISCOUNT
  Non-hierarchy (1): EMPLOYEE
  Not generated here: CUSTORDER, LINEITEM, STOCKEVENT, INVREPORT (order/transaction generators)
"""
import os
import sys
from dataclasses import dataclass, field
from datetime import datetime

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
import config
from hash_utils import make_hub_id, to_hex
from csv_writer import DvCsvWriter

# ── Timestamps ──────────────────────────────────────────────────────────────
# All reference entities are loaded once at a fixed timestamp.
LOAD_TS       = datetime(2025, 9, 30, 0, 0, 0)
EFFECTIVE_FROM = datetime(2025, 9, 30, 0, 0, 0)
EFFECTIVE_TO  = datetime(9999, 12, 31, 23, 59, 59)
CURRENT_FLAG  = 1
IS_DELETED    = 0
SRC_POS       = config.POS_SRC
SRC_INV       = config.INVENTORY_SRC


# ── Column lists ─────────────────────────────────────────────────────────────

HUB_COLS = ["HUB_ID", "SRC", "IS_DELETED", "LOAD_TS"]

SAT_BASE = ["HUB_ID", "SRC", "LOAD_TS", "EFFECTIVEFROM", "EFFECTIVETO",
            "CURRENT_FLAG", "IS_DELETED"]

def _hier_cols(entity: str, extra: list[str] = None) -> list[str]:
    """Return SAT column list for a hierarchy entity."""
    cols = SAT_BASE + [
        f"{entity}_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL",
        "ATTR_1", "ATTR_2", "ATTR_3", "ATTR_4", "ATTR_5",
        f"{entity}_ID", "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN",
    ]
    if extra:
        # Insert extra cols just before the trailing ID/MICROSERVICE block
        insert_at = cols.index(f"{entity}_ID")
        for i, col in enumerate(extra):
            cols.insert(insert_at + i, col)
    return cols


def _sat_row(hub_id: bytes, src: str, name: str, parent_id, level_name: str,
             bottom_level, attr1=None, attr2=None, attr3=None, attr4=None,
             attr5=None, entity_id: str = None, ms_name: str = None,
             extra_values: list = None) -> list:
    """Assemble a standard hierarchy satellite row."""
    row = [
        hub_id, src, LOAD_TS, EFFECTIVE_FROM, EFFECTIVE_TO,
        CURRENT_FLAG, IS_DELETED,
        name, parent_id, level_name, bottom_level,
        attr1, attr2, attr3, attr4, attr5,
        entity_id, entity_id,           # {ENTITY}_ID, MICROSERVICE_ID
        ms_name if ms_name else name,   # MICROSERVICE_NAME
        hub_id,                         # MICROSERVICE_ID_BIN
    ]
    if extra_values:
        # Insert extra values before the trailing ID block
        # trailing block starts at index 17 (entity_id position)
        for i, v in enumerate(extra_values):
            row.insert(17 + i, v)
    return row


# ── LOCATION ──────────────────────────────────────────────────────────────────

def _gen_location(output_dir: str) -> dict:
    """Generate hub_location.csv + sat_location.csv. Returns {loc_id: hub_id bytes}."""
    hub_path = os.path.join(output_dir, "hub_location.csv")
    sat_path = os.path.join(output_dir, "sat_location.csv")
    cols = _hier_cols("LOCATION")
    ids = {}

    chain = config.LOCATION_HIERARCHY["chain"]
    cities = config.LOCATION_HIERARCHY["cities"]
    city_map = config.LOCATION_HIERARCHY["city_map"]

    # Build city → super-category lookup (all cities → chain)
    city_ids = {c["id"]: c for c in cities}

    with DvCsvWriter(hub_path, HUB_COLS) as hub, \
         DvCsvWriter(sat_path, cols) as sat:

        # TOP — chain
        hub_id = make_hub_id(chain["id"], SRC_POS)
        ids[chain["id"]] = hub_id
        hub.writerow([hub_id, SRC_POS, IS_DELETED, LOAD_TS])
        sat.writerow(_sat_row(
            hub_id, SRC_POS,
            name=chain["name"], parent_id=None,
            level_name="TOP", bottom_level=0,
            entity_id=chain["id"], ms_name=chain["name"],
        ))

        # MIDDLE_1 — cities
        for city in cities:
            hub_id = make_hub_id(city["id"], SRC_POS)
            ids[city["id"]] = hub_id
            hub.writerow([hub_id, SRC_POS, IS_DELETED, LOAD_TS])
            sat.writerow(_sat_row(
                hub_id, SRC_POS,
                name=city["name"], parent_id=chain["id"],
                level_name="MIDDLE_1", bottom_level=0,
                entity_id=city["id"], ms_name=city["name"],
            ))

        # BOTTOM — individual locations
        for loc in config.LOCATIONS:
            hub_id = make_hub_id(loc["id"], SRC_POS)
            ids[loc["id"]] = hub_id
            city_id = city_map[loc["id"]]
            hub.writerow([hub_id, SRC_POS, IS_DELETED, LOAD_TS])
            sat.writerow(_sat_row(
                hub_id, SRC_POS,
                name=loc["name"], parent_id=city_id,
                level_name="BOTTOM", bottom_level=1,
                entity_id=loc["id"], ms_name=loc["name"],
            ))

    return ids


# ── PRODUCT ───────────────────────────────────────────────────────────────────

def _gen_product(output_dir: str) -> tuple[dict, dict]:
    """Generate hub_product.csv + sat_product.csv.
    Returns ({prod_id: hub_id}, {prod_id: cat_id})."""
    hub_path = os.path.join(output_dir, "hub_product.csv")
    sat_path = os.path.join(output_dir, "sat_product.csv")
    cols = _hier_cols("PRODUCT")
    ids = {}
    product_categories = {}

    # Build cat → super-cat lookup
    cat_to_scat = {}
    for scat in config.PRODUCT_SUPER_CATEGORIES:
        for cat_id in scat["children"]:
            cat_to_scat[cat_id] = scat["id"]

    with DvCsvWriter(hub_path, HUB_COLS) as hub, \
         DvCsvWriter(sat_path, cols) as sat:

        # TOP — super-categories
        for scat in config.PRODUCT_SUPER_CATEGORIES:
            hub_id = make_hub_id(scat["id"], SRC_POS)
            ids[scat["id"]] = hub_id
            hub.writerow([hub_id, SRC_POS, IS_DELETED, LOAD_TS])
            sat.writerow(_sat_row(
                hub_id, SRC_POS,
                name=scat["name"], parent_id=None,
                level_name="TOP", bottom_level=0,
                entity_id=scat["id"], ms_name=scat["name"],
            ))

        # MIDDLE_1 — categories
        for cat in config.CATEGORIES:
            scat_id = cat_to_scat[cat["id"]]
            hub_id = make_hub_id(cat["id"], SRC_POS)
            ids[cat["id"]] = hub_id
            hub.writerow([hub_id, SRC_POS, IS_DELETED, LOAD_TS])
            sat.writerow(_sat_row(
                hub_id, SRC_POS,
                name=cat["name"], parent_id=scat_id,
                level_name="MIDDLE_1", bottom_level=0,
                entity_id=cat["id"], ms_name=cat["name"],
            ))

        # BOTTOM — products
        for prod in config.PRODUCTS:
            hub_id = make_hub_id(prod["id"], SRC_POS)
            ids[prod["id"]] = hub_id
            product_categories[prod["id"]] = prod["cat"]
            hub.writerow([hub_id, SRC_POS, IS_DELETED, LOAD_TS])
            sat.writerow(_sat_row(
                hub_id, SRC_POS,
                name=prod["name"], parent_id=prod["cat"],
                level_name="BOTTOM", bottom_level=1,
                entity_id=prod["id"], ms_name=prod["name"],
            ))

    return ids, product_categories


# ── INVITEM ───────────────────────────────────────────────────────────────────

def _gen_invitem(output_dir: str) -> dict:
    """Generate hub_invitem.csv + sat_invitem.csv. Returns {invitem_id: hub_id}."""
    hub_path = os.path.join(output_dir, "hub_invitem.csv")
    sat_path = os.path.join(output_dir, "sat_invitem.csv")
    cols = _hier_cols("INVITEM", extra=["UOM"])
    ids = {}

    super_cat = config.INVITEM_SUPER_CATEGORY

    with DvCsvWriter(hub_path, HUB_COLS) as hub, \
         DvCsvWriter(sat_path, cols) as sat:

        # TOP — single super-category
        hub_id = make_hub_id(super_cat["id"], SRC_INV)
        ids[super_cat["id"]] = hub_id
        hub.writerow([hub_id, SRC_INV, IS_DELETED, LOAD_TS])
        row = _sat_row(
            hub_id, SRC_INV,
            name=super_cat["name"], parent_id=None,
            level_name="TOP", bottom_level=0,
            entity_id=super_cat["id"], ms_name=super_cat["name"],
            extra_values=[None],  # UOM
        )
        sat.writerow(row)

        # MIDDLE_1 — categories
        for cat in config.INVITEM_CATEGORIES:
            hub_id = make_hub_id(cat["id"], SRC_INV)
            ids[cat["id"]] = hub_id
            hub.writerow([hub_id, SRC_INV, IS_DELETED, LOAD_TS])
            row = _sat_row(
                hub_id, SRC_INV,
                name=cat["name"], parent_id=super_cat["id"],
                level_name="MIDDLE_1", bottom_level=0,
                entity_id=cat["id"], ms_name=cat["name"],
                extra_values=[None],  # UOM
            )
            sat.writerow(row)

        # BOTTOM — individual ingredients
        for item in config.INVITEMS:
            hub_id = make_hub_id(item["id"], SRC_INV)
            ids[item["id"]] = hub_id
            hub.writerow([hub_id, SRC_INV, IS_DELETED, LOAD_TS])
            row = _sat_row(
                hub_id, SRC_INV,
                name=item["name"], parent_id=item["cat"],
                level_name="BOTTOM", bottom_level=1,
                entity_id=item["id"], ms_name=item["name"],
                extra_values=[item["uom"]],  # UOM
            )
            sat.writerow(row)

    return ids


# ── SUPPLIER ──────────────────────────────────────────────────────────────────

def _gen_supplier(output_dir: str) -> dict:
    """Generate hub_supplier.csv + sat_supplier.csv. Returns {sup_id: hub_id}."""
    hub_path = os.path.join(output_dir, "hub_supplier.csv")
    sat_path = os.path.join(output_dir, "sat_supplier.csv")
    cols = _hier_cols("SUPPLIER")
    ids = {}

    # Single TOP node for suppliers
    sup_top = {"id": "SUPCAT_ALL", "name": "All Suppliers"}

    # Build category → supplier lookup
    cat_names = list(dict.fromkeys(s["category"] for s in config.SUPPLIERS))
    # category id from name (normalise)
    def _cat_id(cat_name: str) -> str:
        return "SUPCAT_" + cat_name.upper().replace(" ", "_").replace("&", "AND")

    sup_cats = [{"id": _cat_id(n), "name": n} for n in cat_names]

    with DvCsvWriter(hub_path, HUB_COLS) as hub, \
         DvCsvWriter(sat_path, cols) as sat:

        # TOP
        hub_id = make_hub_id(sup_top["id"], SRC_INV)
        ids[sup_top["id"]] = hub_id
        hub.writerow([hub_id, SRC_INV, IS_DELETED, LOAD_TS])
        sat.writerow(_sat_row(
            hub_id, SRC_INV,
            name=sup_top["name"], parent_id=None,
            level_name="TOP", bottom_level=0,
            entity_id=sup_top["id"], ms_name=sup_top["name"],
        ))

        # MIDDLE_1 — supplier categories
        for cat in sup_cats:
            hub_id = make_hub_id(cat["id"], SRC_INV)
            ids[cat["id"]] = hub_id
            hub.writerow([hub_id, SRC_INV, IS_DELETED, LOAD_TS])
            sat.writerow(_sat_row(
                hub_id, SRC_INV,
                name=cat["name"], parent_id=sup_top["id"],
                level_name="MIDDLE_1", bottom_level=0,
                entity_id=cat["id"], ms_name=cat["name"],
            ))

        # BOTTOM — individual suppliers
        for sup in config.SUPPLIERS:
            hub_id = make_hub_id(sup["id"], SRC_INV)
            ids[sup["id"]] = hub_id
            cat_id = _cat_id(sup["category"])
            hub.writerow([hub_id, SRC_INV, IS_DELETED, LOAD_TS])
            sat.writerow(_sat_row(
                hub_id, SRC_INV,
                name=sup["name"], parent_id=cat_id,
                level_name="BOTTOM", bottom_level=1,
                entity_id=sup["id"], ms_name=sup["name"],
            ))

    return ids


# ── OCCASION ──────────────────────────────────────────────────────────────────

def _gen_occasion(output_dir: str) -> dict:
    """Generate hub_occasion.csv + sat_occasion.csv. Returns {occ_id: hub_id}."""
    hub_path = os.path.join(output_dir, "hub_occasion.csv")
    sat_path = os.path.join(output_dir, "sat_occasion.csv")
    cols = _hier_cols("OCCASION")
    ids = {}

    occ_top = {"id": "OCC_ALL", "name": "All Occasions"}

    with DvCsvWriter(hub_path, HUB_COLS) as hub, \
         DvCsvWriter(sat_path, cols) as sat:

        # TOP
        hub_id = make_hub_id(occ_top["id"], SRC_POS)
        ids[occ_top["id"]] = hub_id
        hub.writerow([hub_id, SRC_POS, IS_DELETED, LOAD_TS])
        sat.writerow(_sat_row(
            hub_id, SRC_POS,
            name=occ_top["name"], parent_id=None,
            level_name="TOP", bottom_level=0,
            entity_id=occ_top["id"], ms_name=occ_top["name"],
        ))

        # No MIDDLE_1 tier — occasions go directly BOTTOM→TOP
        # (flat list with a single top node for hierarchy completeness)
        for occ in config.OCCASIONS:
            hub_id = make_hub_id(occ["id"], SRC_POS)
            ids[occ["id"]] = hub_id
            hub.writerow([hub_id, SRC_POS, IS_DELETED, LOAD_TS])
            sat.writerow(_sat_row(
                hub_id, SRC_POS,
                name=occ["name"], parent_id=occ_top["id"],
                level_name="BOTTOM", bottom_level=1,
                entity_id=occ["id"], ms_name=occ["name"],
            ))

    return ids


# ── TENDER ────────────────────────────────────────────────────────────────────

def _gen_tender(output_dir: str) -> dict:
    """Generate hub_tender.csv + sat_tender.csv. Returns {tnd_id: hub_id}."""
    hub_path = os.path.join(output_dir, "hub_tender.csv")
    sat_path = os.path.join(output_dir, "sat_tender.csv")
    cols = _hier_cols("TENDER")
    ids = {}

    tnd_top = {"id": "TND_ALL", "name": "All Tenders"}

    with DvCsvWriter(hub_path, HUB_COLS) as hub, \
         DvCsvWriter(sat_path, cols) as sat:

        # TOP
        hub_id = make_hub_id(tnd_top["id"], SRC_POS)
        ids[tnd_top["id"]] = hub_id
        hub.writerow([hub_id, SRC_POS, IS_DELETED, LOAD_TS])
        sat.writerow(_sat_row(
            hub_id, SRC_POS,
            name=tnd_top["name"], parent_id=None,
            level_name="TOP", bottom_level=0,
            entity_id=tnd_top["id"], ms_name=tnd_top["name"],
        ))

        for tnd in config.TENDERS:
            hub_id = make_hub_id(tnd["id"], SRC_POS)
            ids[tnd["id"]] = hub_id
            hub.writerow([hub_id, SRC_POS, IS_DELETED, LOAD_TS])
            sat.writerow(_sat_row(
                hub_id, SRC_POS,
                name=tnd["name"], parent_id=tnd_top["id"],
                level_name="BOTTOM", bottom_level=1,
                entity_id=tnd["id"], ms_name=tnd["name"],
            ))

    return ids


# ── TAX ───────────────────────────────────────────────────────────────────────

def _gen_tax(output_dir: str) -> dict:
    """Generate hub_tax.csv + sat_tax.csv. Returns {tax_id: hub_id}."""
    hub_path = os.path.join(output_dir, "hub_tax.csv")
    sat_path = os.path.join(output_dir, "sat_tax.csv")
    cols = _hier_cols("TAX")
    ids = {}

    tax_top = {"id": "TAX_ALL", "name": "All Tax Rates"}

    with DvCsvWriter(hub_path, HUB_COLS) as hub, \
         DvCsvWriter(sat_path, cols) as sat:

        # TOP
        hub_id = make_hub_id(tax_top["id"], SRC_POS)
        ids[tax_top["id"]] = hub_id
        hub.writerow([hub_id, SRC_POS, IS_DELETED, LOAD_TS])
        sat.writerow(_sat_row(
            hub_id, SRC_POS,
            name=tax_top["name"], parent_id=None,
            level_name="TOP", bottom_level=0,
            entity_id=tax_top["id"], ms_name=tax_top["name"],
        ))

        for tax in config.TAX_RATES:
            hub_id = make_hub_id(tax["id"], SRC_POS)
            ids[tax["id"]] = hub_id
            hub.writerow([hub_id, SRC_POS, IS_DELETED, LOAD_TS])
            # TAX_MULTIPLIER stored in ATTR_1
            sat.writerow(_sat_row(
                hub_id, SRC_POS,
                name=tax["name"], parent_id=tax_top["id"],
                level_name="BOTTOM", bottom_level=1,
                attr1=str(tax["multiplier"]),
                entity_id=tax["id"], ms_name=tax["name"],
            ))

    return ids


# ── REVCENTER ─────────────────────────────────────────────────────────────────

def _gen_revcenter(output_dir: str) -> dict:
    """Generate hub_revcenter.csv + sat_revcenter.csv. Returns {rc_id: hub_id}.
    One REVCENTER per location. BOTTOM_LEVEL is NVARCHAR(255) — output as string."""
    hub_path = os.path.join(output_dir, "hub_revcenter.csv")
    sat_path = os.path.join(output_dir, "sat_revcenter.csv")
    cols = _hier_cols("REVCENTER")
    ids = {}

    rc_top = {"id": "RC_ALL", "name": "All Revenue Centers"}

    with DvCsvWriter(hub_path, HUB_COLS) as hub, \
         DvCsvWriter(sat_path, cols) as sat:

        # TOP
        hub_id = make_hub_id(rc_top["id"], SRC_POS)
        ids[rc_top["id"]] = hub_id
        hub.writerow([hub_id, SRC_POS, IS_DELETED, LOAD_TS])
        sat.writerow(_sat_row(
            hub_id, SRC_POS,
            name=rc_top["name"], parent_id=None,
            level_name="TOP", bottom_level="0",   # string per NVARCHAR(255) type
            entity_id=rc_top["id"], ms_name=rc_top["name"],
        ))

        for loc in config.LOCATIONS:
            rc_id = f"RC_{loc['id']}"
            rc_name = f"{loc['name']} — Bar & Restaurant"
            hub_id = make_hub_id(rc_id, SRC_POS)
            ids[rc_id] = hub_id
            hub.writerow([hub_id, SRC_POS, IS_DELETED, LOAD_TS])
            sat.writerow(_sat_row(
                hub_id, SRC_POS,
                name=rc_name, parent_id=rc_top["id"],
                level_name="BOTTOM", bottom_level="1",   # NVARCHAR(255)
                entity_id=rc_id, ms_name=rc_name,
            ))

    return ids


# ── DISCOUNT ──────────────────────────────────────────────────────────────────

def _gen_discount(output_dir: str) -> dict:
    """Generate hub_discount.csv + sat_discount.csv. Returns {disc_id: hub_id}."""
    hub_path = os.path.join(output_dir, "hub_discount.csv")
    sat_path = os.path.join(output_dir, "sat_discount.csv")
    cols = _hier_cols("DISCOUNT")
    ids = {}

    disc_top = {"id": "DISC_ALL", "name": "All Discounts"}

    with DvCsvWriter(hub_path, HUB_COLS) as hub, \
         DvCsvWriter(sat_path, cols) as sat:

        # TOP
        hub_id = make_hub_id(disc_top["id"], SRC_POS)
        ids[disc_top["id"]] = hub_id
        hub.writerow([hub_id, SRC_POS, IS_DELETED, LOAD_TS])
        sat.writerow(_sat_row(
            hub_id, SRC_POS,
            name=disc_top["name"], parent_id=None,
            level_name="TOP", bottom_level=0,
            entity_id=disc_top["id"], ms_name=disc_top["name"],
        ))

        for disc in config.DISCOUNTS:
            hub_id = make_hub_id(disc["id"], SRC_POS)
            ids[disc["id"]] = hub_id
            hub.writerow([hub_id, SRC_POS, IS_DELETED, LOAD_TS])
            # VALUE_TYPE → ATTR_1, VALUE → ATTR_2, IS_WASTE → ATTR_3
            sat.writerow(_sat_row(
                hub_id, SRC_POS,
                name=disc["name"], parent_id=disc_top["id"],
                level_name="BOTTOM", bottom_level=1,
                attr1=disc.get("value_type"),
                attr2=str(disc.get("value")) if disc.get("value") is not None else None,
                attr3="0",  # IS_WASTE = False for all configured discounts
                entity_id=disc["id"], ms_name=disc["name"],
            ))

    return ids


# ── EMPLOYEE ──────────────────────────────────────────────────────────────────

SAT_EMPLOYEE_COLS = SAT_BASE + [
    "SURNAME", "FIRST_NAME", "MIDDLE_NAME", "POST_DESC",
    "ACTIVE_DATE", "END_DATE", "PAYTYPE", "TRONC_OPTOUT_DATE",
    "MICROSERVICE_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID_BIN",
]


def _gen_employee(output_dir: str) -> tuple[dict, dict]:
    """Generate hub_employee.csv + sat_employee.csv.
    Returns ({emp_id: hub_id}, {loc_id: [emp_ids]})."""
    hub_path = os.path.join(output_dir, "hub_employee.csv")
    sat_path = os.path.join(output_dir, "sat_employee.csv")
    ids = {}
    location_employees: dict[str, list] = {loc["id"]: [] for loc in config.LOCATIONS}

    # 5 employees per location; EMPLOYEE_NAMES ordered by location in config
    locs = config.LOCATIONS
    names = config.EMPLOYEE_NAMES  # 30 entries, 5 per location

    with DvCsvWriter(hub_path, HUB_COLS) as hub, \
         DvCsvWriter(sat_path, SAT_EMPLOYEE_COLS) as sat:

        for idx, (first, last, role) in enumerate(names):
            loc = locs[idx // 5]
            emp_id = f"EMP{idx + 1:03d}"
            hub_id = make_hub_id(emp_id, SRC_POS)
            ids[emp_id] = hub_id
            location_employees[loc["id"]].append(emp_id)

            hub.writerow([hub_id, SRC_POS, IS_DELETED, LOAD_TS])

            # ACTIVE_DATE as DECIMAL(38,10): e.g. 20251001.0000000000
            active_date_decimal = float("20251001")

            ms_name = f"{first} {last}"
            sat.writerow([
                hub_id, SRC_POS, LOAD_TS, EFFECTIVE_FROM, EFFECTIVE_TO,
                CURRENT_FLAG, IS_DELETED,
                last,           # SURNAME
                first,          # FIRST_NAME
                None,           # MIDDLE_NAME
                role,           # POST_DESC
                active_date_decimal,  # ACTIVE_DATE (DECIMAL)
                None,           # END_DATE
                "SALARY",       # PAYTYPE
                None,           # TRONC_OPTOUT_DATE
                emp_id,         # MICROSERVICE_ID
                ms_name,        # MICROSERVICE_NAME
                hub_id,         # MICROSERVICE_ID_BIN
            ])

    return ids, location_employees


# ── DATACLASS ────────────────────────────────────────────────────────────────

@dataclass
class ReferenceData:
    locations:          dict   # loc_id → hub_id (bytes)
    products:           dict   # prod_id → hub_id
    invitems:           dict   # invitem_id → hub_id
    suppliers:          dict   # sup_id → hub_id
    employees:          dict   # emp_id → hub_id
    occasions:          dict   # occ_id → hub_id
    tenders:            dict   # tnd_id → hub_id
    taxes:              dict   # tax_id → hub_id
    revcenters:         dict   # rc_id → hub_id
    discounts:          dict   # disc_id → hub_id
    location_employees: dict   # loc_id → [emp_ids]
    product_categories: dict   # prod_id → cat_id


# ── PUBLIC ENTRY POINT ────────────────────────────────────────────────────────

def generate_reference_data(output_dir: str) -> ReferenceData:
    """Generate all reference entity CSVs.  Returns a ReferenceData with hub-ID lookups."""
    os.makedirs(output_dir, exist_ok=True)

    location_ids              = _gen_location(output_dir)
    product_ids, prod_cats    = _gen_product(output_dir)
    invitem_ids               = _gen_invitem(output_dir)
    supplier_ids              = _gen_supplier(output_dir)
    occasion_ids              = _gen_occasion(output_dir)
    tender_ids                = _gen_tender(output_dir)
    tax_ids                   = _gen_tax(output_dir)
    revcenter_ids             = _gen_revcenter(output_dir)
    discount_ids              = _gen_discount(output_dir)
    employee_ids, loc_emps    = _gen_employee(output_dir)

    # Filter returned dicts to only the leaf-level IDs callers care about
    # (strip TOP/MIDDLE intermediates — callers need bottom-level keys only)
    return ReferenceData(
        locations          = {k: v for k, v in location_ids.items()
                              if k.startswith("LOC")},
        products           = {k: v for k, v in product_ids.items()
                              if k.startswith("PROD")},
        invitems           = {k: v for k, v in invitem_ids.items()
                              if k.startswith("INV")},
        suppliers          = {k: v for k, v in supplier_ids.items()
                              if k.startswith("SUP")},
        employees          = employee_ids,
        occasions          = {k: v for k, v in occasion_ids.items()
                              if k.startswith("OCC")},
        tenders            = {k: v for k, v in tender_ids.items()
                              if k.startswith("TND")},
        taxes              = {k: v for k, v in tax_ids.items()
                              if k.startswith("TAX") and k != "TAX_ALL"},
        revcenters         = {k: v for k, v in revcenter_ids.items()
                              if k.startswith("RC_LOC")},
        discounts          = {k: v for k, v in discount_ids.items()
                              if k.startswith("DISC") and k != "DISC_ALL"},
        location_employees = loc_emps,
        product_categories = prod_cats,
    )
