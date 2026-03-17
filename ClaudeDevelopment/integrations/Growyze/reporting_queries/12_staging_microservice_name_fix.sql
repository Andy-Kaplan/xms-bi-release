/*
    12_staging_microservice_name_fix.sql
    ====================================
    Fix: Remove hardcoded 'growyze' from MICROSERVICE_NAME in staging steps

    Root cause:
        4 Growyze staging steps hardcode 'growyze' AS MICROSERVICE_NAME.
        MICROSERVICE_NAME is an MDM (Master Data Management) column — it should
        only be populated manually for cross-integration product alignment.
        When populated by the pipeline, COALESCE(MICROSERVICE_NAME, NATIVE_NAME)
        in all vis queries resolves to 'growyze' instead of the real item name.

    Affected staging steps:
        - Growyze Inventory Items  (GRYZ_INVITEMS)  — 3 occurrences (item/subcat/cat)
        - Growyze Location         (GRYZ_LOCATION)   — 1 occurrence
        - Growyze Product          (GRYZ_PRODUCT)     — 2+ occurrences (product/cat)
        - Growyze Suppliers        (GRYZ_SUPPLIERS)   — 1 occurrence

    After deploying this fix:
        1. Run the staging process (re-creates GRYZ_* tables with NULL MICROSERVICE_NAME)
        2. Run DV load (updates SAT_PRODUCT, SAT_INVITEM, SAT_LOCATION, SAT_SUPPLIER)
        3. Run presentation build (rebuilds D_PRODUCT, D_INVITEM, D_LOCATION)
        Dashboard vis queries will then resolve real item/category/location names.

    Run against: core database (per-org int_growyze001 schema)
    Idempotent: Yes — WHERE clause checks the old pattern still exists
*/

-- Fix all 4 staging steps in one UPDATE using REPLACE
-- REPLACE catches every occurrence within each query_sql (multiple UNION ALL branches)
UPDATE [int_growyze001].[StagingControl]
SET query_sql = REPLACE(
        query_sql,
        N'''growyze'' AS MICROSERVICE_NAME',
        N'NULL AS MICROSERVICE_NAME'
    ),
    updated_at = GETDATE()
WHERE step_name IN (
    'Growyze Inventory Items',
    'Growyze Location',
    'Growyze Product',
    'Growyze Suppliers'
)
AND step_type = 'Staging'
AND query_sql LIKE N'%''growyze'' AS MICROSERVICE_NAME%';
