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
