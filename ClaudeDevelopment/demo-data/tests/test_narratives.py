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
