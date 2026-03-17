/*
    14_null_microservice_columns.sql
    =================================
    Nulls out incorrectly-populated MICROSERVICE columns in the Data Vault
    satellites and presentation dimensions for Growyze orgs.

    Background:
        Growyze staging steps hardcoded 'growyze' AS MICROSERVICE_NAME.
        MICROSERVICE_* columns are reserved for manual MDM entry only.
        Script 12 prevents future loads from setting these values;
        this script cleans up the existing data in-place so that a
        full history reload is not required.

    Affected tables (Padel Social UAT counts):
        datavault.SAT_PRODUCT   — 2,183 rows
        datavault.SAT_INVITEM   — 3,490 rows
        datavault.SAT_LOCATION  —     7 rows
        datavault.SAT_SUPPLIER  —    89 rows
        presentation.D_PRODUCT  — 2,179 rows
        presentation.D_INVITEM  — 3,363 rows
        presentation.D_LOCATION —     7 rows
        presentation.D_SUPPLIER —     0 rows (no data, included for completeness)

    Safety: Only updates rows WHERE MICROSERVICE_NAME = 'growyze'.
            Manually-entered MDM values (if any) are untouched.

    Run against: Growyze client database (e.g. Padel Social)
    Idempotent: Yes — second run updates 0 rows
*/

-- =========================================================
-- Data Vault satellite tables
-- =========================================================

UPDATE [datavault].[SAT_PRODUCT]
SET MICROSERVICE_NAME = NULL,
    MICROSERVICE_ID = NULL,
    MICROSERVICE_ID_BIN = NULL
WHERE MICROSERVICE_NAME = N'growyze';

UPDATE [datavault].[SAT_INVITEM]
SET MICROSERVICE_NAME = NULL,
    MICROSERVICE_ID = NULL,
    MICROSERVICE_ID_BIN = NULL
WHERE MICROSERVICE_NAME = N'growyze';

UPDATE [datavault].[SAT_LOCATION]
SET MICROSERVICE_NAME = NULL,
    MICROSERVICE_ID = NULL,
    MICROSERVICE_ID_BIN = NULL
WHERE MICROSERVICE_NAME = N'growyze';

UPDATE [datavault].[SAT_SUPPLIER]
SET MICROSERVICE_NAME = NULL,
    MICROSERVICE_ID = NULL,
    MICROSERVICE_ID_BIN = NULL
WHERE MICROSERVICE_NAME = N'growyze';

-- =========================================================
-- Presentation dimension tables
-- All three hierarchy tiers: BOTTOM, MIDDLE_1, TOP
-- =========================================================

UPDATE [presentation].[D_PRODUCT]
SET BOTTOM_MICROSERVICE_NAME = NULL, BOTTOM_MICROSERVICE_ID = NULL,
    MIDDLE_1_MICROSERVICE_NAME = NULL, MIDDLE_1_MICROSERVICE_ID = NULL,
    TOP_MICROSERVICE_NAME = NULL, TOP_MICROSERVICE_ID = NULL
WHERE BOTTOM_MICROSERVICE_NAME = N'growyze'
   OR MIDDLE_1_MICROSERVICE_NAME = N'growyze'
   OR TOP_MICROSERVICE_NAME = N'growyze';

UPDATE [presentation].[D_INVITEM]
SET BOTTOM_MICROSERVICE_NAME = NULL, BOTTOM_MICROSERVICE_ID = NULL,
    MIDDLE_1_MICROSERVICE_NAME = NULL, MIDDLE_1_MICROSERVICE_ID = NULL,
    TOP_MICROSERVICE_NAME = NULL, TOP_MICROSERVICE_ID = NULL
WHERE BOTTOM_MICROSERVICE_NAME = N'growyze'
   OR MIDDLE_1_MICROSERVICE_NAME = N'growyze'
   OR TOP_MICROSERVICE_NAME = N'growyze';

UPDATE [presentation].[D_LOCATION]
SET BOTTOM_MICROSERVICE_NAME = NULL, BOTTOM_MICROSERVICE_ID = NULL,
    MIDDLE_1_MICROSERVICE_NAME = NULL, MIDDLE_1_MICROSERVICE_ID = NULL,
    TOP_MICROSERVICE_NAME = NULL, TOP_MICROSERVICE_ID = NULL
WHERE BOTTOM_MICROSERVICE_NAME = N'growyze'
   OR MIDDLE_1_MICROSERVICE_NAME = N'growyze'
   OR TOP_MICROSERVICE_NAME = N'growyze';

UPDATE [presentation].[D_SUPPLIER]
SET BOTTOM_MICROSERVICE_NAME = NULL, BOTTOM_MICROSERVICE_ID = NULL,
    MIDDLE_1_MICROSERVICE_NAME = NULL, MIDDLE_1_MICROSERVICE_ID = NULL,
    TOP_MICROSERVICE_NAME = NULL, TOP_MICROSERVICE_ID = NULL
WHERE BOTTOM_MICROSERVICE_NAME = N'growyze'
   OR MIDDLE_1_MICROSERVICE_NAME = N'growyze'
   OR TOP_MICROSERVICE_NAME = N'growyze';
