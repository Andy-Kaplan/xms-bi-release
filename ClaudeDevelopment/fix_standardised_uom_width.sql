/*
    Fix: Widen STANDARDISED_UOM from VARCHAR(2) to VARCHAR(255)
    Target: Each affected org database
    Date: 2026-03-11

    Problem: STANDARDISED_UOM column defined as VARCHAR(2) — too narrow for
    standard UOM values from the UOM_CONVERSION reference table:
      percentage (10), portion (7), each (4), ml (2), g (1)

    The value 'each' truncates to 'ea', causing error:
      "String or binary data would be truncated in table ...F_INV_USAGE_DAY,
       column 'STANDARDISED_UOM'. Truncated value: 'ea'."

    Affected tables (2):
      - [presentation].[F_INV_COUNTS_DAY]
      - [presentation].[F_INV_USAGE_DAY]

    Deploy: Run against each org database that has these presentation tables.
    Safe to run multiple times — ALTER COLUMN is idempotent.
*/

-- F_INV_COUNTS_DAY
ALTER TABLE [presentation].[F_INV_COUNTS_DAY]
    ALTER COLUMN [STANDARDISED_UOM] [varchar](255) NULL;

-- F_INV_USAGE_DAY
ALTER TABLE [presentation].[F_INV_USAGE_DAY]
    ALTER COLUMN [STANDARDISED_UOM] [varchar](255) NULL;
