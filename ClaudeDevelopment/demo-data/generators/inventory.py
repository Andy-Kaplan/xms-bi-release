"""
Inventory generator — produces STOCKEVENT + INVREPORT hub/sat/link CSVs.

Output files (8 CSVs):
  hub_stockevent.csv, sat_stockevent.csv
  hub_invreport.csv, sat_invreport.csv
  lnk_invitem_stockevent.csv
  lnk_location_stockevent.csv
  lnk_invitem_invreport.csv
  lnk_invreport_location.csv

All AGG columns = 0. SRC = config.INVENTORY_SRC for all rows.

STOCKEVENT business key: "{event_type}|{loc_id}|{inv_id}|{date}"
INVREPORT business key:  "{loc_id}|{inv_id}|{week_end_date}"
"""

import os
import sys
import random
from datetime import date, timedelta, datetime
from collections import defaultdict

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

import config
from hash_utils import make_hub_id, make_lnk_id
from csv_writer import DvCsvWriter
from generators.reference_data import ReferenceData
from generators.recipes import RecipeData
from generators.narratives import get_waste_multiplier, get_ingredient_cost_multiplier

# ── Constants ─────────────────────────────────────────────────────────────────

SRC = config.INVENTORY_SRC
IS_DELETED = 0
CURRENT_FLAG = 1
EFFECTIVE_TO = datetime(9999, 12, 31, 23, 59, 59)
AGG_ZERO = 0

# Load timestamp — same inception point as reference data
LOAD_TS = datetime(2025, 9, 30, 0, 0, 0)

# ── Column definitions ────────────────────────────────────────────────────────

HUB_COLS = ["HUB_ID", "SRC", "IS_DELETED", "LOAD_TS"]

SAT_STOCKEVENT_COLS = [
    "HUB_ID", "SRC", "LOAD_TS", "EFFECTIVEFROM", "EFFECTIVETO",
    "CURRENT_FLAG", "IS_DELETED",
    "EVENT_TYPE", "EVENT_TS", "PACK_DESC", "PACK_QUANTITY",
    "UOM", "UOM_QUANITY",   # NOTE: known platform typo — do NOT correct
    "EXTERNAL_REF", "INTERNAL_REF", "EVENT_BEHAVIOUR",
]

SAT_INVREPORT_COLS = [
    "HUB_ID", "SRC", "LOAD_TS", "EFFECTIVEFROM", "EFFECTIVETO",
    "CURRENT_FLAG", "IS_DELETED",
    "THEO_USAGE", "ACTUAL_USAGE", "THEO_COST", "ACTUAL_COST",
    "VARIANCE_QTY", "VARIANCE_VALUE", "WASTE_QTY", "WASTE_VALUE",
    "REPORTING_DATE", "REPORTING_UOM", "UOM_COST",
    "SALES_QTY", "ORDER_QTY", "TRANSFER_QTY",
    "COUNT_FREQUENCY", "COUNT_RECENCY",
]

LNK_INVITEM_STOCKEVENT_COLS = [
    "LNK_ID", "SRC", "LOAD_TS",
    "INVITEM_HUB_ID", "STOCKEVENT_HUB_ID",
    "INVITEM_AGG", "STOCKEVENT_AGG",
]

LNK_LOCATION_STOCKEVENT_COLS = [
    "LNK_ID", "SRC", "LOAD_TS",
    "LOCATION_HUB_ID", "STOCKEVENT_HUB_ID",
    "LOCATION_AGG", "STOCKEVENT_AGG",
]

LNK_INVITEM_INVREPORT_COLS = [
    "LNK_ID", "SRC", "LOAD_TS",
    "INVITEM_HUB_ID", "INVREPORT_HUB_ID",
    "INVITEM_AGG", "INVREPORT_AGG",
]

LNK_INVREPORT_LOCATION_COLS = [
    "LNK_ID", "SRC", "LOAD_TS",
    "INVREPORT_HUB_ID", "LOCATION_HUB_ID",
    "INVREPORT_AGG", "LOCATION_AGG",
]


# ── Helpers ───────────────────────────────────────────────────────────────────

def _event_ts(d: date, hour: int = 8) -> datetime:
    """Convert a date to an event datetime (default 08:00)."""
    return datetime(d.year, d.month, d.day, hour, 0, 0)


def _date_load_ts(d: date) -> datetime:
    """LOAD_TS for transaction rows — day after the event at midnight."""
    next_day = d + timedelta(days=1)
    return datetime(next_day.year, next_day.month, next_day.day, 0, 0, 0)


def _date_range(start: date, end: date):
    """Yield every date from start to end inclusive."""
    current = start
    while current <= end:
        yield current
        current += timedelta(days=1)


def _week_end(d: date) -> date:
    """Return the Sunday >= d (the week-end Sunday that contains d)."""
    days_ahead = 6 - d.weekday()   # Monday=0, Sunday=6
    if days_ahead < 0:
        days_ahead += 7
    return d + timedelta(days=days_ahead)


def _is_order_day(d: date) -> bool:
    """Orders arrive on Monday (0) and Thursday (3)."""
    return d.weekday() in (0, 3)


def _is_count_day(d: date) -> bool:
    """Stock counts happen every Sunday (6)."""
    return d.weekday() == 6


# ── Pre-computation helpers ───────────────────────────────────────────────────

def _build_ingredient_usage_per_product(recipes: RecipeData) -> dict:
    """Returns {prod_id: {inv_id: (qty, uom)}} — per-serving ingredient usage."""
    result = {}
    for prod_id, ingredients in recipes.product_ingredients.items():
        inv_map = {}
        for inv_id, qty, uom in ingredients:
            # In case the same inv_id appears twice in a recipe, accumulate
            if inv_id in inv_map:
                inv_map[inv_id] = (inv_map[inv_id][0] + qty, uom)
            else:
                inv_map[inv_id] = (qty, uom)
        result[prod_id] = inv_map
    return result


def _build_invitem_lookup() -> dict:
    """Returns {inv_id: {uom, cost, supplier}} from config.INVITEMS."""
    return {item["id"]: item for item in config.INVITEMS}


def _build_daily_usage(
    sales: dict,
    ingredient_usage: dict,
    date_str: str,
    loc_id: str,
) -> dict:
    """
    Compute {inv_id: (total_qty, uom)} consumed on a given date at a location
    by multiplying sales quantities by recipe usage.
    """
    day_sales = sales.get(date_str, {}).get(loc_id, {})
    usage: dict[str, list] = {}  # inv_id → [total_qty, uom]

    for prod_id, qty_sold in day_sales.items():
        if qty_sold <= 0:
            continue
        inv_map = ingredient_usage.get(prod_id, {})
        for inv_id, (qty_per_serving, uom) in inv_map.items():
            total = qty_per_serving * qty_sold
            if inv_id in usage:
                usage[inv_id][0] += total
            else:
                usage[inv_id] = [total, uom]

    return {k: (v[0], v[1]) for k, v in usage.items()}


# ── Main generator ─────────────────────────────────────────────────────────────

def generate_inventory(
    output_dir: str,
    ref: ReferenceData,
    recipes: RecipeData,
    sales: dict,
) -> None:
    """Generate all inventory STOCKEVENT + INVREPORT CSVs."""
    random.seed(43)
    os.makedirs(output_dir, exist_ok=True)

    # ── Pre-computed lookups ──────────────────────────────────────────────────
    ingredient_usage = _build_ingredient_usage_per_product(recipes)
    invitem_lookup   = _build_invitem_lookup()

    # All leaf-level invitem IDs — filter to only those that exist in invitem_lookup
    # (ref.invitems also contains category nodes like INVCAT_BEV that start with INV;
    # invitem_lookup is keyed only by the actual ingredient IDs from config.INVITEMS)
    all_inv_ids = [iid for iid in ref.invitems.keys() if iid in invitem_lookup]
    all_loc_ids = list(ref.locations.keys()) # ["LOC001", ..., "LOC006"]

    # Average daily usage per ingredient across all locations (for seeding stock levels
    # and sizing order quantities).
    # We'll compute a rough estimate: assume 50 orders/day × 3.2 items × recipe usage.
    avg_daily_usage_est: dict[str, float] = defaultdict(float)
    for prod_id, inv_map in ingredient_usage.items():
        # Rough probability this product is ordered per order per location
        # (1/80 products × 3.2 items) — used only for stock sizing
        prob = config.AVG_ITEMS_PER_ORDER / len(config.PRODUCTS)
        daily_orders = config.AVG_ORDERS_PER_DAY_PER_LOCATION
        for inv_id, (qty, _uom) in inv_map.items():
            avg_daily_usage_est[inv_id] += qty * prob * daily_orders

    # ── Running stock levels per (loc_id, inv_id) ────────────────────────────
    # Initialise with ~14 days of estimated usage
    stock: dict[tuple, float] = {}
    for loc_id in all_loc_ids:
        for inv_id in all_inv_ids:
            opening = avg_daily_usage_est.get(inv_id, 0.0) * 14.0
            stock[(loc_id, inv_id)] = max(opening, 0.1)

    # ── Weekly accumulators for INVREPORT (reset each Sunday) ────────────────
    # {(loc_id, inv_id): {sale, waste, order, transfer}} for current week
    WeekAcc = dict  # type alias for clarity

    def _empty_acc() -> dict:
        return {"sale": 0.0, "waste": 0.0, "order": 0.0, "transfer": 0.0}

    week_acc: dict[tuple, dict] = defaultdict(_empty_acc)

    # ── Open all output writers ───────────────────────────────────────────────
    hub_se_path  = os.path.join(output_dir, "hub_stockevent.csv")
    sat_se_path  = os.path.join(output_dir, "sat_stockevent.csv")
    hub_ir_path  = os.path.join(output_dir, "hub_invreport.csv")
    sat_ir_path  = os.path.join(output_dir, "sat_invreport.csv")
    lnk_is_path  = os.path.join(output_dir, "lnk_invitem_stockevent.csv")
    lnk_ls_path  = os.path.join(output_dir, "lnk_location_stockevent.csv")
    lnk_ii_path  = os.path.join(output_dir, "lnk_invitem_invreport.csv")
    lnk_rl_path  = os.path.join(output_dir, "lnk_invreport_location.csv")

    with (
        DvCsvWriter(hub_se_path, HUB_COLS) as hub_se,
        DvCsvWriter(sat_se_path, SAT_STOCKEVENT_COLS) as sat_se,
        DvCsvWriter(hub_ir_path, HUB_COLS) as hub_ir,
        DvCsvWriter(sat_ir_path, SAT_INVREPORT_COLS) as sat_ir,
        DvCsvWriter(lnk_is_path, LNK_INVITEM_STOCKEVENT_COLS) as lnk_is,
        DvCsvWriter(lnk_ls_path, LNK_LOCATION_STOCKEVENT_COLS) as lnk_ls,
        DvCsvWriter(lnk_ii_path, LNK_INVITEM_INVREPORT_COLS) as lnk_ii,
        DvCsvWriter(lnk_rl_path, LNK_INVREPORT_LOCATION_COLS) as lnk_rl,
    ):

        def _write_stockevent(
            event_type: str,
            event_behaviour: str,
            loc_id: str,
            inv_id: str,
            d: date,
            quantity: float,
            uom: str,
            pack_desc: str = None,
            external_ref: str = None,
            internal_ref: str = None,
        ) -> None:
            """Write one STOCKEVENT hub+sat+links row."""
            bk = f"{event_type}|{loc_id}|{inv_id}|{d.isoformat()}"
            hub_id  = make_hub_id(bk, SRC)
            load_ts = _date_load_ts(d)
            ev_ts   = _event_ts(d)
            eff_from = datetime(d.year, d.month, d.day, 0, 0, 0)

            inv_hub_id = ref.invitems[inv_id]
            loc_hub_id = ref.locations[loc_id]

            # Hub
            hub_se.writerow([hub_id, SRC, IS_DELETED, load_ts])

            # Sat
            sat_se.writerow([
                hub_id, SRC, load_ts, eff_from, EFFECTIVE_TO,
                CURRENT_FLAG, IS_DELETED,
                event_type, ev_ts,
                pack_desc,      # PACK_DESC
                None,           # PACK_QUANTITY
                uom,            # UOM
                round(quantity, 6),  # UOM_QUANITY (typo intentional)
                external_ref,   # EXTERNAL_REF
                internal_ref,   # INTERNAL_REF
                event_behaviour,
            ])

            # LNK_INVITEM_STOCKEVENT
            lnk_id = make_lnk_id(inv_hub_id, hub_id, src=SRC)
            lnk_is.writerow([lnk_id, SRC, load_ts,
                              inv_hub_id, hub_id, AGG_ZERO, AGG_ZERO])

            # LNK_LOCATION_STOCKEVENT
            lnk_id2 = make_lnk_id(loc_hub_id, hub_id, src=SRC)
            lnk_ls.writerow([lnk_id2, SRC, load_ts,
                              loc_hub_id, hub_id, AGG_ZERO, AGG_ZERO])

        # ── Determine weekly top-30 usage ranking ─────────────────────────────
        # Pre-rank all INV items by their estimated average daily usage
        # so INVREPORT selects the top-30 most-used per location
        ranked_inv_ids = sorted(
            all_inv_ids,
            key=lambda iid: avg_daily_usage_est.get(iid, 0.0),
            reverse=True,
        )
        top30_inv_ids = set(ranked_inv_ids[:30])

        # Track the last count date per (loc_id, inv_id) for COUNT_RECENCY
        last_count_date: dict[tuple, date] = {}

        # ── Main loop: iterate over every day ────────────────────────────────
        for d in _date_range(config.START_DATE, config.END_DATE):
            date_str = d.isoformat()
            dow = d.weekday()   # 0=Mon … 6=Sun

            # ── 1. SALE events ─────────────────────────────────────────────
            for loc_id in all_loc_ids:
                daily_usage = _build_daily_usage(sales, ingredient_usage, date_str, loc_id)

                for inv_id, (qty, uom) in daily_usage.items():
                    if qty <= 0 or inv_id not in ref.invitems:
                        continue
                    _write_stockevent(
                        event_type="SALE",
                        event_behaviour="-",
                        loc_id=loc_id,
                        inv_id=inv_id,
                        d=d,
                        quantity=qty,
                        uom=uom,
                        internal_ref=f"SALES_{date_str}",
                    )
                    stock[(loc_id, inv_id)] = max(
                        stock.get((loc_id, inv_id), 0.0) - qty, 0.0
                    )
                    week_acc[(loc_id, inv_id)]["sale"] += qty

            # ── 2. WASTE events ────────────────────────────────────────────
            # Random ~10-20% of active ingredients per location
            for loc_id in all_loc_ids:
                waste_multiplier = get_waste_multiplier(loc_id, d)
                # Number of ingredients to waste today: 10-20% of all_inv_ids
                n_waste = random.randint(
                    max(1, len(all_inv_ids) // 10),
                    max(2, len(all_inv_ids) // 5),
                )
                waste_candidates = random.sample(all_inv_ids, n_waste)

                for inv_id in waste_candidates:
                    if inv_id not in ref.invitems:
                        continue
                    item_cfg = invitem_lookup[inv_id]
                    uom = item_cfg["uom"]

                    sale_qty = week_acc[(loc_id, inv_id)]["sale"]
                    if sale_qty > 0:
                        # 2–5% of daily sale quantity (estimated as 1/7 of weekly so far)
                        base_daily_sale = sale_qty / max(dow + 1, 1)
                        waste_pct = random.uniform(0.02, 0.05)
                        waste_qty = base_daily_sale * waste_pct * waste_multiplier
                    else:
                        # Small fixed waste for items not used today
                        daily_est = avg_daily_usage_est.get(inv_id, 0.0)
                        waste_qty = daily_est * random.uniform(0.01, 0.03) * waste_multiplier

                    waste_qty = round(max(waste_qty, 0.0), 6)
                    if waste_qty <= 0:
                        continue

                    _write_stockevent(
                        event_type="WASTE",
                        event_behaviour="-",
                        loc_id=loc_id,
                        inv_id=inv_id,
                        d=d,
                        quantity=waste_qty,
                        uom=uom,
                        internal_ref=f"WASTE_{date_str}",
                    )
                    stock[(loc_id, inv_id)] = max(
                        stock.get((loc_id, inv_id), 0.0) - waste_qty, 0.0
                    )
                    week_acc[(loc_id, inv_id)]["waste"] += waste_qty

            # ── 3. ORDER events ────────────────────────────────────────────
            if _is_order_day(d):
                for loc_id in all_loc_ids:
                    # Replenish items with low stock: ~7 days × avg usage × 1.2
                    # Order every active ingredient that has reasonable usage
                    for inv_id in all_inv_ids:
                        if inv_id not in ref.invitems:
                            continue
                        item_cfg = invitem_lookup[inv_id]
                        uom = item_cfg["uom"]

                        avg_daily = avg_daily_usage_est.get(inv_id, 0.0)
                        if avg_daily <= 0:
                            continue

                        # Only order if stock is below 10-day threshold
                        current_stock = stock.get((loc_id, inv_id), 0.0)
                        reorder_point = avg_daily * 5.0
                        if current_stock > reorder_point:
                            continue

                        order_qty = avg_daily * 7.0 * 1.2
                        order_qty = round(max(order_qty, 0.01), 6)

                        _write_stockevent(
                            event_type="ORDER",
                            event_behaviour="+",
                            loc_id=loc_id,
                            inv_id=inv_id,
                            d=d,
                            quantity=order_qty,
                            uom=uom,
                            external_ref=f"PO_{date_str}_{loc_id}_{inv_id}",
                            internal_ref=f"ORDER_{date_str}",
                        )
                        stock[(loc_id, inv_id)] = (
                            stock.get((loc_id, inv_id), 0.0) + order_qty
                        )
                        week_acc[(loc_id, inv_id)]["order"] += order_qty

            # ── 4. TRANSFER events ─────────────────────────────────────────
            # 1–2 transfers per week across the chain (random day check)
            # On average: 1.5 transfers/week = ~0.21/day probability
            if random.random() < 0.21:
                n_transfers = random.randint(1, 2)
                for _ in range(n_transfers):
                    if len(all_loc_ids) < 2:
                        break
                    src_loc, dst_loc = random.sample(all_loc_ids, 2)
                    inv_id = random.choice(all_inv_ids)
                    if inv_id not in ref.invitems:
                        continue
                    item_cfg = invitem_lookup[inv_id]
                    uom = item_cfg["uom"]

                    avg_daily = avg_daily_usage_est.get(inv_id, 0.0)
                    transfer_qty = avg_daily * random.uniform(0.5, 2.0)
                    transfer_qty = round(max(transfer_qty, 0.01), 6)

                    ref_tag = f"TRF_{date_str}_{src_loc}_{dst_loc}"

                    # Outbound from source
                    _write_stockevent(
                        event_type="TRANSFER",
                        event_behaviour="-",
                        loc_id=src_loc,
                        inv_id=inv_id,
                        d=d,
                        quantity=transfer_qty,
                        uom=uom,
                        internal_ref=ref_tag,
                        external_ref=f"OUT_{ref_tag}",
                    )
                    stock[(src_loc, inv_id)] = max(
                        stock.get((src_loc, inv_id), 0.0) - transfer_qty, 0.0
                    )
                    week_acc[(src_loc, inv_id)]["transfer"] += transfer_qty

                    # Inbound to destination
                    _write_stockevent(
                        event_type="TRANSFER",
                        event_behaviour="+",
                        loc_id=dst_loc,
                        inv_id=inv_id,
                        d=d,
                        quantity=transfer_qty,
                        uom=uom,
                        internal_ref=ref_tag,
                        external_ref=f"IN_{ref_tag}",
                    )
                    stock[(dst_loc, inv_id)] = (
                        stock.get((dst_loc, inv_id), 0.0) + transfer_qty
                    )
                    week_acc[(dst_loc, inv_id)]["transfer"] += transfer_qty

            # ── 5. COUNT events + INVREPORT (every Sunday) ─────────────────
            if _is_count_day(d):
                for loc_id in all_loc_ids:
                    loc_hub_id = ref.locations[loc_id]

                    for inv_id in all_inv_ids:
                        if inv_id not in ref.invitems:
                            continue
                        item_cfg = invitem_lookup[inv_id]
                        uom = item_cfg["uom"]

                        current_stock = stock.get((loc_id, inv_id), 0.0)

                        # COUNT event
                        _write_stockevent(
                            event_type="COUNT",
                            event_behaviour="COUNT",
                            loc_id=loc_id,
                            inv_id=inv_id,
                            d=d,
                            quantity=max(current_stock, 0.0),
                            uom=uom,
                            internal_ref=f"COUNT_{date_str}",
                        )

                        key = (loc_id, inv_id)
                        last_count_date[key] = d

                    # ── INVREPORT for top-30 ingredients ──────────────────
                    for inv_id in top30_inv_ids:
                        if inv_id not in ref.invitems:
                            continue
                        item_cfg = invitem_lookup[inv_id]
                        uom = item_cfg["uom"]
                        base_cost = item_cfg["cost"]
                        uom_cost = base_cost * get_ingredient_cost_multiplier(inv_id, d)

                        key = (loc_id, inv_id)
                        acc = week_acc[key]

                        sale_qty     = acc["sale"]
                        waste_qty    = acc["waste"]
                        order_qty    = acc["order"]
                        transfer_qty = acc["transfer"]

                        theo_usage    = sale_qty
                        actual_usage  = sale_qty + waste_qty
                        theo_cost     = round(theo_usage   * uom_cost, 4)
                        actual_cost   = round(actual_usage * uom_cost, 4)
                        variance_qty  = round(actual_usage - theo_usage, 6)
                        variance_val  = round(variance_qty * uom_cost, 4)
                        waste_value   = round(waste_qty    * uom_cost, 4)

                        # COUNT_RECENCY — days since last count (7 on a normal week, 0 on first)
                        last_cnt = last_count_date.get(key)
                        if last_cnt and last_cnt < d:
                            count_recency = (d - last_cnt).days
                        else:
                            count_recency = 0

                        # INVREPORT hub business key: loc|inv|week_end_date
                        ir_bk = f"{loc_id}|{inv_id}|{d.isoformat()}"
                        ir_hub_id = make_hub_id(ir_bk, SRC)
                        load_ts_ir = _date_load_ts(d)
                        eff_from_ir = datetime(d.year, d.month, d.day, 0, 0, 0)

                        inv_hub_id = ref.invitems[inv_id]

                        # Hub
                        hub_ir.writerow([ir_hub_id, SRC, IS_DELETED, load_ts_ir])

                        # Sat
                        sat_ir.writerow([
                            ir_hub_id, SRC, load_ts_ir, eff_from_ir, EFFECTIVE_TO,
                            CURRENT_FLAG, IS_DELETED,
                            round(theo_usage, 6),
                            round(actual_usage, 6),
                            theo_cost,
                            actual_cost,
                            round(variance_qty, 6),
                            variance_val,
                            round(waste_qty, 6),
                            waste_value,
                            d,           # REPORTING_DATE
                            uom,         # REPORTING_UOM
                            round(uom_cost, 4),  # UOM_COST
                            round(sale_qty, 6),
                            round(order_qty, 6),
                            round(transfer_qty, 6),
                            7,           # COUNT_FREQUENCY (weekly)
                            count_recency,
                        ])

                        # LNK_INVITEM_INVREPORT
                        lnk_id_ii = make_lnk_id(inv_hub_id, ir_hub_id, src=SRC)
                        lnk_ii.writerow([lnk_id_ii, SRC, load_ts_ir,
                                         inv_hub_id, ir_hub_id, AGG_ZERO, AGG_ZERO])

                        # LNK_INVREPORT_LOCATION
                        lnk_id_rl = make_lnk_id(ir_hub_id, loc_hub_id, src=SRC)
                        lnk_rl.writerow([lnk_id_rl, SRC, load_ts_ir,
                                         ir_hub_id, loc_hub_id, AGG_ZERO, AGG_ZERO])

                # Reset weekly accumulators after Sunday report
                week_acc = defaultdict(_empty_acc)

    print(f"  hub_stockevent:         {hub_se.row_count:,} rows")
    print(f"  sat_stockevent:         {sat_se.row_count:,} rows")
    print(f"  lnk_invitem_stockevent: {lnk_is.row_count:,} rows")
    print(f"  lnk_location_stockevent:{lnk_ls.row_count:,} rows")
    print(f"  hub_invreport:          {hub_ir.row_count:,} rows")
    print(f"  sat_invreport:          {sat_ir.row_count:,} rows")
    print(f"  lnk_invitem_invreport:  {lnk_ii.row_count:,} rows")
    print(f"  lnk_invreport_location: {lnk_rl.row_count:,} rows")
