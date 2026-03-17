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
    print("[2/4] Recipes (ingredient -> product mappings)...")
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
