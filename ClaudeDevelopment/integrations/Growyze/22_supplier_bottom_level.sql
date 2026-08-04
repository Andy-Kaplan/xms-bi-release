-- ============================================================================
-- Growyze suppliers: set BOTTOM_LEVEL so presentation.D_SUPPLIER can build
-- Ledger: O23  (unblocks the 9th Marge Brut card, O8)
--
-- ROOT CAUSE (proven on UAT, The Oak & Vine org 16 + Ibis Gloucester Road org 21)
-- The global `Supplier Dimension` step in core.core.PresentationControl anchors
-- its recursive hierarchy CTE on:
--       FROM [datavault].[SAT_SUPPLIER] WHERE BOTTOM_LEVEL = 1 AND CURRENT_FLAG = 1
-- Every Growyze SAT_SUPPLIER row has BOTTOM_LEVEL = NULL, so the anchor matches
-- nothing, the recursion never starts, and no Growyze supplier reaches D_SUPPLIER.
-- Consequence: all 2,438 F_PURCHASES_DAY lines (GBP 25,002.57) fail
--       JOIN D_SUPPLIER sup ON sup.BOTTOM_HUB_ID = p.SUPPLIER_HUB_ID
-- so MargeBrutPurchasesBySupplier returns 0 data rows. Its header TotalValue
-- subquery does NOT join D_SUPPLIER, which is why the card still shows a
-- headline (GBP 22,544.37) above an empty plot -- that asymmetry is what
-- isolated the fault to the dimension rather than the purchases fact.
--
-- The omission is Growyze-specific. Of the five Growyze staging steps feeding a
-- D_* dimension, only Suppliers fails to declare and set the column:
--     Growyze Inventory Items / Location / Occasion / Product  -> all set it
--     Growyze Suppliers                                        -> does not
-- MarketMan's supplier staging does set it (int_marketman001 rows carry
-- BOTTOM_LEVEL = 1), which is why The Oak & Vine's D_SUPPLIER holds 7 rows
-- (6 MarketMan + sentinel) yet still matches no Growyze purchase key.
--
-- FIX SHAPE
-- Growyze suppliers are a FLAT dimension -- all 8 rows have PARENT_ID IS NULL --
-- so every row is simply BOTTOM_LEVEL = 1 and is its own top level. This is the
-- identical shape to `Growyze Location`, whose single flat row produces a valid
-- D_LOCATION row with BOTTOM/MIDDLE_1/TOP all self-populated (verified on UAT).
-- This script therefore mirrors `Growyze Location` exactly.
--
-- *** DELIBERATELY NOT CARRYING MICROSERVICE_NAME -- READ BEFORE "COMPLETING" THIS ***
-- stage.GRYZ_SUPPLIERS sets MICROSERVICE_NAME to the literal string 'growyze'
-- (as GRYZ_LOCATION does). The SUPPLIER EntityMappings row below must NOT carry
-- that column into SAT_SUPPLIER, for two independent reasons:
--   1. MargeBrutPurchasesBySupplier labels bars with
--          COALESCE(sup.BOTTOM_MICROSERVICE_NAME, sup.BOTTOM_SUPPLIER_NAME)
--      so a populated MICROSERVICE_NAME would collapse Bidfood, Reynolds
--      Catering and Matthew Clark into ONE bar named "growyze" -- swapping an
--      empty chart for a silently wrong one.
--   2. MICROSERVICE_NAME is the MDM display-name layer: manual entry only,
--      pipelines must leave it NULL (CLAUDE.md "Key Conventions"). It is the
--      resolver in ~82 vis-query COALESCE sites.
-- The four working sibling mappings all omit it, and SAT_SUPPLIER.MICROSERVICE_NAME
-- is currently NULL for both int_growyze001 and int_marketman001. Keep it that way.
--
-- Deploy target: core.  After deploy:
--   EXEC [core].[core].[UploadEntityMappings]
--        @intSchema = N'int_growyze001', @entity = N'SUPPLIER';
-- to regenerate the `Data Vault load - SUPPLIER` StagingControl step from the
-- mapping row updated in (b).
--   * There is NO `UploadStagingControl` procedure -- the staging step edited in
--     (a) is the live artefact and needs no regeneration.
--   * @entity is scoped to SUPPLIER deliberately. An unscoped call regenerates
--     every Growyze entity, and multi-source entities are known to collide
--     (error 8156 / silent last-source-wins). One entity, one blast radius.
-- Then, per Growyze org: staging -> DV load -> rebuild the `Supplier Dimension`
-- step ONLY. Do NOT run DeployPresentationTables -- it DROPs every registered
-- presentation table (see O8). Runner: 94_deploy_supplier_bottom_level.ps1.
--
-- Idempotent: wholesale UPDATE of both control rows; re-running changes nothing.
-- ============================================================================

SET NOCOUNT ON;

-- ---------------------------------------------------------------------------
-- (a) Staging: declare and set LEVEL_NAME / BOTTOM_LEVEL / PARENT_ID.
--     Bare `NULL AS PARENT_ID` and `1 AS BOTTOM_LEVEL` match the four working
--     sibling steps exactly (GRYZ_LOCATION lands them as int NULL / int NOT NULL
--     and core.fnCleanForDisplay handles both in the Load step).
-- ---------------------------------------------------------------------------
UPDATE [core].[int_growyze001].[StagingControl]
SET updated_at = GETDATE(),
    staging_columns = N'["HUB_ID", "SUPPLIER_NAME", "SUPPLIER_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "PARENT_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID"]',
    query_sql = N'IF OBJECT_ID(''stage.GRYZ_SUPPLIERS'', ''U'') IS NOT NULL
    DROP TABLE [stage].[GRYZ_SUPPLIERS];
WITH prod_suppliers AS (
    SELECT DISTINCT supplierId AS supplier_id, supplierName AS supplier_name
    FROM [int_growyze001].[DL_PRODUCTS]
    WHERE supplierId IS NOT NULL
),
order_suppliers AS (
    SELECT DISTINCT supplier_id, supplier_name
    FROM [int_growyze001].[DL_ORDERS]
    WHERE supplier_id IS NOT NULL
)
SELECT * INTO [stage].[GRYZ_SUPPLIERS]
FROM (
    SELECT
        COALESCE(p.supplier_id, o.supplier_id) AS HUB_ID,
        COALESCE(o.supplier_name, p.supplier_name) AS SUPPLIER_NAME,
        COALESCE(p.supplier_id, o.supplier_id) AS SUPPLIER_ID,
        ''Supplier'' AS LEVEL_NAME,
        1 AS BOTTOM_LEVEL,
        NULL AS PARENT_ID,
        ''growyze'' AS MICROSERVICE_NAME,
        COALESCE(p.supplier_id, o.supplier_id) AS MICROSERVICE_ID
    FROM prod_suppliers p
    FULL OUTER JOIN order_suppliers o ON p.supplier_id = o.supplier_id
) AS source_query;'
WHERE step_name = N'Growyze Suppliers';

IF @@ROWCOUNT <> 1
    RAISERROR(N'(a) FAILED: expected exactly 1 StagingControl row named ''Growyze Suppliers''.', 16, 1);

-- ---------------------------------------------------------------------------
-- (b) EntityMappings: carry the three hierarchy columns through to SAT_SUPPLIER.
--     Column order and hash flags mirror the LOCATION mapping exactly.
--     UploadEntityMappings regenerates the `Data Vault load - SUPPLIER`
--     StagingControl step from this row -- editing that step directly would be
--     overwritten on the next regeneration, which is why the change lands here.
-- ---------------------------------------------------------------------------
UPDATE [core].[int_growyze001].[EntityMappings]
SET updated_at = GETDATE(),
    source_columns = N'[{"name": "HUB_ID", "hash": 1}, {"name": "SUPPLIER_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "SUPPLIER_ID", "hash": 0}]',
    entity_columns = N'["HUB_ID", "SUPPLIER_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "SUPPLIER_ID"]'
WHERE entity_name = N'SUPPLIER';

IF @@ROWCOUNT <> 1
    RAISERROR(N'(b) FAILED: expected exactly 1 EntityMappings row named ''SUPPLIER''.', 16, 1);

-- ---------------------------------------------------------------------------
-- (c) Verify the control plane now matches its working siblings.
--     Both rows must report HAS. Run the two Upload* procs afterwards.
-- ---------------------------------------------------------------------------
SELECT
    N'StagingControl: Growyze Suppliers' AS Check_Name,
    CASE WHEN staging_columns LIKE N'%BOTTOM[_]LEVEL%'
          AND query_sql       LIKE N'%1 AS BOTTOM[_]LEVEL%'
         THEN N'HAS' ELSE N'MISSING' END AS Verdict
FROM [core].[int_growyze001].[StagingControl]
WHERE step_name = N'Growyze Suppliers'
UNION ALL
SELECT
    N'EntityMappings: SUPPLIER',
    CASE WHEN source_columns LIKE N'%BOTTOM[_]LEVEL%'
          AND entity_columns LIKE N'%BOTTOM[_]LEVEL%'
          AND source_columns NOT LIKE N'%MICROSERVICE[_]NAME%'   -- must stay absent
         THEN N'HAS' ELSE N'MISSING' END
FROM [core].[int_growyze001].[EntityMappings]
WHERE entity_name = N'SUPPLIER';
