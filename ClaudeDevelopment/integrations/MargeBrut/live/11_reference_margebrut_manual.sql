-- ============================================
-- 11_reference_margebrut_manual.sql
-- Creates reference.MARGEBRUT_MANUAL and seeds the Oct-2025 ISLRG figures.
--
-- Part of the Marge Brut mock -> live build (Task 2).
--
-- Holds the manual inputs no data feed provides for the Marge Brut grid:
-- Reverse/New stock provisions, the staff-meal cost figure, and the comp
-- cost % assumption. Keyed by (GROUP_NAME, PERIOD_MONTH) so the Task 6
-- build step can LEFT JOIN it onto the feed-derived columns. Real periods
-- get their own rows added here later; this seed only covers Oct-2025 so
-- the grid reconciles to the sheet for that period.
--
-- `reference` schema confirmed to already exist on client DBs via MCP
-- (INFORMATION_SCHEMA.SCHEMATA against the Growyze proxy org) - no
-- CREATE SCHEMA guard needed.
-- ============================================

IF OBJECT_ID(N'[reference].[MARGEBRUT_MANUAL]') IS NULL
CREATE TABLE [reference].[MARGEBRUT_MANUAL](
    [GROUP_NAME] NVARCHAR(50) NOT NULL,
    [PERIOD_MONTH] DATE NOT NULL,
    [REV_PROV] DECIMAL(18,2) NOT NULL DEFAULT 0,
    [NEW_PROV] DECIMAL(18,2) NOT NULL DEFAULT 0,
    [STAFF_MEAL] DECIMAL(18,2) NOT NULL DEFAULT 0,
    [COMP_COST_PCT] DECIMAL(9,4) NOT NULL DEFAULT 0,
    CONSTRAINT [PK_MARGEBRUT_MANUAL] PRIMARY KEY ([GROUP_NAME],[PERIOD_MONTH])
);

-- Oct-2025 ISLRG sheet figures. Only "Food" carries non-zero
-- Reverse/New provisions and a staff-meal cost (the sheet's TOTAL FOOD
-- row); the other five groups have none for this period. Comp cost %
-- is the sheet's flat 33% assumption, applied across all groups.
MERGE INTO [reference].[MARGEBRUT_MANUAL] AS tgt
USING (VALUES
    (N'Food',        '2025-10-01', 1092.60, 912.17, 306.40, 0.33),
    (N'Breakfast',   '2025-10-01',    0.00,   0.00,   0.00, 0.33),
    (N'Wines',       '2025-10-01',    0.00,   0.00,   0.00, 0.33),
    (N'Bottled Beer','2025-10-01',    0.00,   0.00,   0.00, 0.33),
    (N'Soft Drinks', '2025-10-01',    0.00,   0.00,   0.00, 0.33),
    (N'Spirit',      '2025-10-01',    0.00,   0.00,   0.00, 0.33)
) AS src (GROUP_NAME, PERIOD_MONTH, REV_PROV, NEW_PROV, STAFF_MEAL, COMP_COST_PCT)
ON tgt.GROUP_NAME = src.GROUP_NAME AND tgt.PERIOD_MONTH = src.PERIOD_MONTH
WHEN MATCHED THEN UPDATE SET
    REV_PROV = src.REV_PROV,
    NEW_PROV = src.NEW_PROV,
    STAFF_MEAL = src.STAFF_MEAL,
    COMP_COST_PCT = src.COMP_COST_PCT
WHEN NOT MATCHED THEN INSERT
    (GROUP_NAME, PERIOD_MONTH, REV_PROV, NEW_PROV, STAFF_MEAL, COMP_COST_PCT)
    VALUES (src.GROUP_NAME, src.PERIOD_MONTH, src.REV_PROV, src.NEW_PROV, src.STAFF_MEAL, src.COMP_COST_PCT);
