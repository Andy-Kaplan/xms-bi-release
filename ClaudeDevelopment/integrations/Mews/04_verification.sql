/* ============================================================================
   Mews Integration - Verification Script
   Read-only (SELECT/WITH only). Every check emits four columns:
   check_name, expected, actual, status (PASS/FAIL, or INVESTIGATE for the
   one financial-reconciliation report row that is informational, not a gate).

   Five sections, run at different pipeline stages:
     A. Control-plane counts   - run against `core`, BEFORE deployment and
                                  again immediately after 01+02 are deployed
     B. Stage table counts     - run in the org DB, AFTER sp_Staging
     C. Data-quality gates     - run in the org DB, AFTER sp_Staging
     D. Post-load DV counts    - run in the org DB, AFTER sp_DataVaultLoad
     E. Presentation checks    - run in the org DB, AFTER the presentation
                                  layer rebuild completes

   Section A queries use three-part [core].[int_mews001].[...] naming because
   they run from the `core` database's own connection (per the brief's exact
   template). Sections B-E use unqualified two-part names because they run
   inside the target organisation's database - never prefix with a client DB
   name in this file.

   Expected-count baselines are the 2026-07-03 live observations recorded in
   Tasks 1-5 (see task-1..5-report.md), NOT the task-6-brief.md literals -
   two values were corrected after Task 6 briefing was written:
     - MEWS_CHANNEL: 2 -> 1 (area "Rooms" confirmed inactive; filter stands)
     - MEWS_LINEITEM_TAX (stage) and LNK_LINEITEM_TAX (DV): compare to
       DL-side derivation, not the literal 17
   Where the source system may have landed more data since, checks compare
   against a DL-side derivation instead of a hardcoded literal (flagged per
   check below).

   Spec: docs/superpowers/specs/2026-07-03-mews-dv-mapping-design.md
   Plan: docs/superpowers/plans/2026-07-03-mews-dv-mapping.md
   Task brief: .superpowers/sdd/task-6-brief.md (+ plan-preamble.md)
   Created: 2026-07-03
   ============================================================================ */


/* ============================================================================
   SECTION A: Control-plane counts
   Run against: `core` database
   When: before deployment (expect 0/0/0, all FAIL - this is the correct
         pre-deploy observation) and again immediately after 01_staging_
         control.sql + 02_entity_mappings.sql + 03_upload_load_steps.sql are
         deployed (expect 17/25/25, all PASS)
   ============================================================================ */

SELECT 'staging_steps' AS check_name, '17' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 17 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [core].[int_mews001].[StagingControl] WHERE step_type = 'Staging' AND exclude = 0;

SELECT 'load_steps_generated' AS check_name, '25' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 25 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [core].[int_mews001].[StagingControl] WHERE step_type = 'Load' AND exclude = 0;

SELECT 'entity_mappings' AS check_name, '25' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 25 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [core].[int_mews001].[EntityMappings] WHERE is_active = 1;


/* ============================================================================
   SECTION B: Stage table counts
   Run in: the organisation's own database
   When: after sp_Staging has executed all 17 Mews staging steps
   ============================================================================ */

-- Dimensions (tier 1)
SELECT 'stage_MEWS_LOCATION' AS check_name, '2' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 2 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [stage].[MEWS_LOCATION];

SELECT 'stage_MEWS_PRODUCT_total' AS check_name, '389' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 389 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [stage].[MEWS_PRODUCT]
UNION ALL
SELECT 'stage_MEWS_PRODUCT_TOP', '12',
       CAST(COUNT(*) AS VARCHAR(10)),
       CASE WHEN COUNT(*) = 12 THEN 'PASS' ELSE 'FAIL' END
FROM [stage].[MEWS_PRODUCT] WHERE LEVEL_NAME = 'TOP'
UNION ALL
SELECT 'stage_MEWS_PRODUCT_MIDDLE_1', '98',
       CAST(COUNT(*) AS VARCHAR(10)),
       CASE WHEN COUNT(*) = 98 THEN 'PASS' ELSE 'FAIL' END
FROM [stage].[MEWS_PRODUCT] WHERE LEVEL_NAME = 'MIDDLE_1'
UNION ALL
SELECT 'stage_MEWS_PRODUCT_BOTTOM', '279',
       CAST(COUNT(*) AS VARCHAR(10)),
       CASE WHEN COUNT(*) = 279 THEN 'PASS' ELSE 'FAIL' END
FROM [stage].[MEWS_PRODUCT] WHERE LEVEL_NAME = 'BOTTOM';

SELECT 'stage_MEWS_MOD' AS check_name, '0' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [stage].[MEWS_MOD];

SELECT 'stage_MEWS_TAX' AS check_name, '1' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [stage].[MEWS_TAX];

SELECT 'stage_MEWS_TENDER' AS check_name, '6' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 6 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [stage].[MEWS_TENDER];

SELECT 'stage_MEWS_DISCOUNT' AS check_name, '2' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 2 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [stage].[MEWS_DISCOUNT];

-- CHANNEL: expected is 1, not 2 - area "Rooms" is confirmed inactive in the
-- source and the isActive filter deliberately excludes it (ruling stands).
SELECT 'stage_MEWS_CHANNEL' AS check_name, '1' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [stage].[MEWS_CHANNEL];

SELECT 'stage_MEWS_REVCENTER' AS check_name, '0' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [stage].[MEWS_REVCENTER];

-- Transactional (tier 1)
SELECT 'stage_MEWS_CUSTORDER' AS check_name, '19' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 19 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [stage].[MEWS_CUSTORDER];

SELECT 'stage_MEWS_LINEITEM_total' AS check_name, '22' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 22 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [stage].[MEWS_LINEITEM]
UNION ALL
SELECT 'stage_MEWS_LINEITEM_void', '5',
       CAST(COUNT(*) AS VARCHAR(10)),
       CASE WHEN COUNT(*) = 5 THEN 'PASS' ELSE 'FAIL' END
FROM [stage].[MEWS_LINEITEM] WHERE VOID_FLAG = 1;

-- LINEITEM_TAX: compare to the DL-side derivation mirroring step 11's own
-- filter (deduped non-cancelled invoice items with non-zero tax), NOT the
-- literal 17 - this is the explicit exception called out in the corrected
-- baselines. Both DL tables are deduped via rn = 1 exactly as step 11 does,
-- so a re-fetch (duplicate rows per id) cannot inflate the expected count.
WITH ii AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn
    FROM [int_mews001].[DL_INVOICE_ITEMS]
),
inv AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn
    FROM [int_mews001].[DL_INVOICES]
),
dl AS (
    SELECT COUNT(*) AS n
    FROM ii
    INNER JOIN inv ON inv.id = ii.invoiceId AND inv.rn = 1
    WHERE ii.rn = 1
      AND COALESCE(inv.cancelled, '0') <> '1'
      AND CAST(ii.tax AS DECIMAL(18,2)) <> 0
),
st AS (
    SELECT COUNT(*) AS n FROM [stage].[MEWS_LINEITEM_TAX]
)
SELECT 'stage_MEWS_LINEITEM_TAX' AS check_name,
       CAST(dl.n AS VARCHAR(10)) AS expected,
       CAST(st.n AS VARCHAR(10)) AS actual,
       CASE WHEN dl.n = st.n THEN 'PASS' ELSE 'FAIL' END AS status
FROM dl CROSS JOIN st;

SELECT 'stage_MEWS_LINEITEM_DISCOUNT' AS check_name, '0' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [stage].[MEWS_LINEITEM_DISCOUNT];

-- CRM (tier 1)
SELECT 'stage_MEWS_CUSTOMER' AS check_name, '364' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 364 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [stage].[MEWS_CUSTOMER];

-- ADDRESS: genuine source gap, not a failure. No Mews customer currently has
-- any address component populated. The check PASSES on equality with the
-- DL-side derivation (both sides are 0 today; if Mews starts returning
-- address data both sides will move together). DL_CUSTOMERS is deduped via
-- rn = 1 exactly as step 14 does, mirroring its filter so a re-fetch cannot
-- inflate the expected count.
WITH deduped AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn
    FROM [int_mews001].[DL_CUSTOMERS]
),
dl AS (
    SELECT COUNT(*) AS n
    FROM deduped
    WHERE rn = 1
      AND COALESCE(NULLIF(address1, ''), NULLIF(address2, ''),
                    NULLIF(city, ''), NULLIF(postalCode, '')) IS NOT NULL
),
st AS (
    SELECT COUNT(*) AS n FROM [stage].[MEWS_ADDRESS]
)
SELECT 'stage_MEWS_ADDRESS' AS check_name,
       CAST(dl.n AS VARCHAR(10)) AS expected,
       CAST(st.n AS VARCHAR(10)) AS actual,
       CASE WHEN dl.n = st.n THEN 'PASS' ELSE 'FAIL' END AS status
FROM dl CROSS JOIN st;

SELECT 'stage_MEWS_CONTACT_total' AS check_name, '257' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 257 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [stage].[MEWS_CONTACT]
UNION ALL
SELECT 'stage_MEWS_CONTACT_EMAIL', '185',
       CAST(COUNT(*) AS VARCHAR(10)),
       CASE WHEN COUNT(*) = 185 THEN 'PASS' ELSE 'FAIL' END
FROM [stage].[MEWS_CONTACT] WHERE CONTACT_TYPE = 'EMAIL'
UNION ALL
SELECT 'stage_MEWS_CONTACT_PHONE', '72',
       CAST(COUNT(*) AS VARCHAR(10)),
       CASE WHEN COUNT(*) = 72 THEN 'PASS' ELSE 'FAIL' END
FROM [stage].[MEWS_CONTACT] WHERE CONTACT_TYPE = 'PHONE';

-- Tier-2 link staging (both expected empty on current data)
SELECT 'stage_MEWS_CUSTORDER_REVCENTER_LNK' AS check_name, '0' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [stage].[MEWS_CUSTORDER_REVCENTER_LNK];

SELECT 'stage_MEWS_DISCOUNT_LINEITEM_LNK' AS check_name, '0' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [stage].[MEWS_DISCOUNT_LINEITEM_LNK];


/* ============================================================================
   SECTION C: Data-quality gates
   Run in: the organisation's own database
   When: after sp_Staging (same point as Section B)
   ============================================================================ */

-- HARD GATE: a NULL LINEITEM_TIMESTAMP breaks every downstream date join.
SELECT 'null_lineitem_timestamp' AS check_name, '0' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [stage].[MEWS_LINEITEM] WHERE LINEITEM_TIMESTAMP IS NULL;

-- Single-tax assumption guard: MEWS_LINEITEM_TAX's CROSS JOIN to the sole
-- active tax profile (step 11) breaks silently if a second tax profile
-- appears - escalate rather than let TAX lines mis-attribute.
SELECT 'single_tax_guard' AS check_name, '1' AS expected,
       CAST(COUNT(DISTINCT id) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(DISTINCT id) = 1 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [int_mews001].[DL_TAXES];

-- Every PROD line's PRODUCT_KEY must resolve to a staged BOTTOM product
-- member (stage-side mirror of the Task 5 MCP spot-check, which returned 0).
SELECT 'unresolved_product_keys' AS check_name, '0' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [stage].[MEWS_LINEITEM] li
WHERE NOT EXISTS (
    SELECT 1 FROM [stage].[MEWS_PRODUCT] p
    WHERE p.HUB_ID = li.PRODUCT_KEY AND p.BOTTOM_LEVEL = 1
);

-- Every line item's HEADER_ID must resolve to a staged customer order.
SELECT 'custorder_lineitem_coverage' AS check_name, '0' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [stage].[MEWS_LINEITEM] li
WHERE NOT EXISTS (
    SELECT 1 FROM [stage].[MEWS_CUSTORDER] co WHERE co.HEADER_ID = li.HEADER_ID
);

-- Financial reconciliation: report only, do NOT hard-fail. Comps zero out
-- item totals but the invoice total may retain them, so some drift is
-- expected - a non-zero count here means "go look", not "broken".
SELECT 'financial_reconciliation' AS check_name, 'review' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       'INVESTIGATE' AS status
FROM (
    SELECT co.HEADER_ID
    FROM [stage].[MEWS_CUSTORDER] co
    INNER JOIN (
        SELECT HEADER_ID, SUM(GROSS_VALUE) AS LINE_GROSS
        FROM [stage].[MEWS_LINEITEM]
        WHERE VOID_FLAG = 0
        GROUP BY HEADER_ID
    ) li ON li.HEADER_ID = co.HEADER_ID
    WHERE ABS(li.LINE_GROSS - co.GRAND_TOTAL) > 0.05
) drift;


/* ============================================================================
   SECTION D: Post-load DV counts
   Run in: the organisation's own database
   When: after sp_DataVaultLoad has processed the Mews load steps
   ============================================================================ */

-- Hub counts (dimension hubs mirror stage row counts; HUB_LINEITEM is the
-- derived sum of the three line staging tables, not a hardcoded literal)
SELECT 'hub_HUB_LOCATION' AS check_name, '2' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 2 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[HUB_LOCATION];

SELECT 'hub_HUB_PRODUCT' AS check_name, '389' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 389 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[HUB_PRODUCT];

SELECT 'hub_HUB_MOD' AS check_name, '0' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[HUB_MOD];

SELECT 'hub_HUB_TAX' AS check_name, '1' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[HUB_TAX];

SELECT 'hub_HUB_TENDER' AS check_name, '6' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 6 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[HUB_TENDER];

SELECT 'hub_HUB_DISCOUNT' AS check_name, '2' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 2 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[HUB_DISCOUNT];

SELECT 'hub_HUB_CHANNEL' AS check_name, '1' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[HUB_CHANNEL];

SELECT 'hub_HUB_REVCENTER' AS check_name, '0' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[HUB_REVCENTER];

SELECT 'hub_HUB_CUSTORDER' AS check_name, '19' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 19 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[HUB_CUSTORDER];

WITH stage_total AS (
    SELECT
        (SELECT COUNT(*) FROM [stage].[MEWS_LINEITEM]) +
        (SELECT COUNT(*) FROM [stage].[MEWS_LINEITEM_TAX]) +
        (SELECT COUNT(*) FROM [stage].[MEWS_LINEITEM_DISCOUNT]) AS n
)
SELECT 'hub_HUB_LINEITEM' AS check_name,
       CAST(stage_total.n AS VARCHAR(10)) AS expected,
       CAST((SELECT COUNT(*) FROM [datavault].[HUB_LINEITEM]) AS VARCHAR(10)) AS actual,
       CASE WHEN stage_total.n = (SELECT COUNT(*) FROM [datavault].[HUB_LINEITEM])
            THEN 'PASS' ELSE 'FAIL' END AS status
FROM stage_total;

SELECT 'hub_HUB_INDIVIDUAL' AS check_name, '364' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 364 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[HUB_INDIVIDUAL];

SELECT 'hub_HUB_ADDRESS' AS check_name, '0' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[HUB_ADDRESS];

SELECT 'hub_HUB_CONTACT' AS check_name, '257' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 257 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[HUB_CONTACT];

-- SAT current-flag counts must equal their hub counts (SCD Type 2: exactly
-- one CURRENT_FLAG=1 row per hub member)
SELECT 'sat_SAT_LOCATION_current' AS check_name,
       CAST((SELECT COUNT(*) FROM [datavault].[HUB_LOCATION]) AS VARCHAR(10)) AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = (SELECT COUNT(*) FROM [datavault].[HUB_LOCATION])
            THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[SAT_LOCATION] WHERE CURRENT_FLAG = 1;

SELECT 'sat_SAT_PRODUCT_current' AS check_name,
       CAST((SELECT COUNT(*) FROM [datavault].[HUB_PRODUCT]) AS VARCHAR(10)) AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = (SELECT COUNT(*) FROM [datavault].[HUB_PRODUCT])
            THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[SAT_PRODUCT] WHERE CURRENT_FLAG = 1;

SELECT 'sat_SAT_CUSTORDER_current' AS check_name,
       CAST((SELECT COUNT(*) FROM [datavault].[HUB_CUSTORDER]) AS VARCHAR(10)) AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = (SELECT COUNT(*) FROM [datavault].[HUB_CUSTORDER])
            THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[SAT_CUSTORDER] WHERE CURRENT_FLAG = 1;

SELECT 'sat_SAT_LINEITEM_current' AS check_name,
       CAST((SELECT COUNT(*) FROM [datavault].[HUB_LINEITEM]) AS VARCHAR(10)) AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = (SELECT COUNT(*) FROM [datavault].[HUB_LINEITEM])
            THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[SAT_LINEITEM] WHERE CURRENT_FLAG = 1;

SELECT 'sat_SAT_INDIVIDUAL_current' AS check_name,
       CAST((SELECT COUNT(*) FROM [datavault].[HUB_INDIVIDUAL]) AS VARCHAR(10)) AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = (SELECT COUNT(*) FROM [datavault].[HUB_INDIVIDUAL])
            THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[SAT_INDIVIDUAL] WHERE CURRENT_FLAG = 1;

SELECT 'sat_SAT_MOD_current' AS check_name,
       CAST((SELECT COUNT(*) FROM [datavault].[HUB_MOD]) AS VARCHAR(10)) AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = (SELECT COUNT(*) FROM [datavault].[HUB_MOD])
            THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[SAT_MOD] WHERE CURRENT_FLAG = 1;

SELECT 'sat_SAT_TAX_current' AS check_name,
       CAST((SELECT COUNT(*) FROM [datavault].[HUB_TAX]) AS VARCHAR(10)) AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = (SELECT COUNT(*) FROM [datavault].[HUB_TAX])
            THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[SAT_TAX] WHERE CURRENT_FLAG = 1;

SELECT 'sat_SAT_TENDER_current' AS check_name,
       CAST((SELECT COUNT(*) FROM [datavault].[HUB_TENDER]) AS VARCHAR(10)) AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = (SELECT COUNT(*) FROM [datavault].[HUB_TENDER])
            THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[SAT_TENDER] WHERE CURRENT_FLAG = 1;

SELECT 'sat_SAT_DISCOUNT_current' AS check_name,
       CAST((SELECT COUNT(*) FROM [datavault].[HUB_DISCOUNT]) AS VARCHAR(10)) AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = (SELECT COUNT(*) FROM [datavault].[HUB_DISCOUNT])
            THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[SAT_DISCOUNT] WHERE CURRENT_FLAG = 1;

SELECT 'sat_SAT_CHANNEL_current' AS check_name,
       CAST((SELECT COUNT(*) FROM [datavault].[HUB_CHANNEL]) AS VARCHAR(10)) AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = (SELECT COUNT(*) FROM [datavault].[HUB_CHANNEL])
            THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[SAT_CHANNEL] WHERE CURRENT_FLAG = 1;

SELECT 'sat_SAT_REVCENTER_current' AS check_name,
       CAST((SELECT COUNT(*) FROM [datavault].[HUB_REVCENTER]) AS VARCHAR(10)) AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = (SELECT COUNT(*) FROM [datavault].[HUB_REVCENTER])
            THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[SAT_REVCENTER] WHERE CURRENT_FLAG = 1;

SELECT 'sat_SAT_ADDRESS_current' AS check_name,
       CAST((SELECT COUNT(*) FROM [datavault].[HUB_ADDRESS]) AS VARCHAR(10)) AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = (SELECT COUNT(*) FROM [datavault].[HUB_ADDRESS])
            THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[SAT_ADDRESS] WHERE CURRENT_FLAG = 1;

SELECT 'sat_SAT_CONTACT_current' AS check_name,
       CAST((SELECT COUNT(*) FROM [datavault].[HUB_CONTACT]) AS VARCHAR(10)) AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = (SELECT COUNT(*) FROM [datavault].[HUB_CONTACT])
            THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[SAT_CONTACT] WHERE CURRENT_FLAG = 1;

-- Link counts. LNK_CUSTORDER_LINEITEM is derived to equal HUB_LINEITEM
-- (every line item, tax line, and discount line links back to its order).
WITH hub_lineitem AS (SELECT COUNT(*) AS n FROM [datavault].[HUB_LINEITEM])
SELECT 'lnk_LNK_CUSTORDER_LINEITEM' AS check_name,
       CAST(hub_lineitem.n AS VARCHAR(10)) AS expected,
       CAST((SELECT COUNT(*) FROM [datavault].[LNK_CUSTORDER_LINEITEM]) AS VARCHAR(10)) AS actual,
       CASE WHEN hub_lineitem.n = (SELECT COUNT(*) FROM [datavault].[LNK_CUSTORDER_LINEITEM])
            THEN 'PASS' ELSE 'FAIL' END AS status
FROM hub_lineitem;

SELECT 'lnk_LNK_LINEITEM_PRODUCT' AS check_name, '22' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 22 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[LNK_LINEITEM_PRODUCT];

-- LNK_LINEITEM_TAX: compare to the DL-side derivation mirroring step 11's own
-- filter (deduped non-cancelled invoice items with non-zero tax), NOT the
-- literal 17 - this is the explicit exception called out in the corrected
-- baselines. Both DL tables are deduped via rn = 1 exactly as step 11 does,
-- so a re-fetch (duplicate rows per id) cannot inflate the expected count.
WITH ii AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn
    FROM [int_mews001].[DL_INVOICE_ITEMS]
),
inv AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn
    FROM [int_mews001].[DL_INVOICES]
),
dl AS (
    SELECT COUNT(*) AS n
    FROM ii
    INNER JOIN inv ON inv.id = ii.invoiceId AND inv.rn = 1
    WHERE ii.rn = 1
      AND COALESCE(inv.cancelled, '0') <> '1'
      AND CAST(ii.tax AS DECIMAL(18,2)) <> 0
),
lnk AS (
    SELECT COUNT(*) AS n FROM [datavault].[LNK_LINEITEM_TAX]
)
SELECT 'lnk_LNK_LINEITEM_TAX' AS check_name,
       CAST(dl.n AS VARCHAR(10)) AS expected,
       CAST(lnk.n AS VARCHAR(10)) AS actual,
       CASE WHEN dl.n = lnk.n THEN 'PASS' ELSE 'FAIL' END AS status
FROM dl CROSS JOIN lnk;

SELECT 'lnk_LNK_CUSTORDER_LOCATION' AS check_name, '19' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 19 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[LNK_CUSTORDER_LOCATION];

SELECT 'lnk_LNK_CONTACT_INDIVIDUAL' AS check_name, '257' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 257 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[LNK_CONTACT_INDIVIDUAL];

SELECT 'lnk_LNK_ADDRESS_INDIVIDUAL' AS check_name, '0' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[LNK_ADDRESS_INDIVIDUAL];

SELECT 'lnk_LNK_DISCOUNT_LINEITEM' AS check_name, '0' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[LNK_DISCOUNT_LINEITEM];

SELECT 'lnk_LNK_CUSTORDER_REVCENTER' AS check_name, '0' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[LNK_CUSTORDER_REVCENTER];

-- Orphan-link checks (the Dirty Sixth bug pattern): both sides of all 8
-- distinct Mews link tables must resolve to an existing hub member. Note the
-- 10 EntityMappings link rows (#16-#25) collapse into 8 distinct LNK tables
-- because CUSTORDER_LINEITEM is fed by three source tables (MEWS_LINEITEM,
-- MEWS_LINEITEM_TAX, MEWS_LINEITEM_DISCOUNT) into one link.

SELECT 'orphan_LNK_CUSTORDER_LOCATION_CUSTORDER' AS check_name, '0' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[LNK_CUSTORDER_LOCATION] l
WHERE NOT EXISTS (SELECT 1 FROM [datavault].[HUB_CUSTORDER] h WHERE h.HUB_ID = l.CUSTORDER_HUB_ID);

SELECT 'orphan_LNK_CUSTORDER_LOCATION_LOCATION' AS check_name, '0' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[LNK_CUSTORDER_LOCATION] l
WHERE NOT EXISTS (SELECT 1 FROM [datavault].[HUB_LOCATION] h WHERE h.HUB_ID = l.LOCATION_HUB_ID);

SELECT 'orphan_LNK_CUSTORDER_LINEITEM_LINEITEM' AS check_name, '0' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[LNK_CUSTORDER_LINEITEM] l
WHERE NOT EXISTS (SELECT 1 FROM [datavault].[HUB_LINEITEM] h WHERE h.HUB_ID = l.LINEITEM_HUB_ID);

SELECT 'orphan_LNK_CUSTORDER_LINEITEM_CUSTORDER' AS check_name, '0' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[LNK_CUSTORDER_LINEITEM] l
WHERE NOT EXISTS (SELECT 1 FROM [datavault].[HUB_CUSTORDER] h WHERE h.HUB_ID = l.CUSTORDER_HUB_ID);

SELECT 'orphan_LNK_LINEITEM_PRODUCT_LINEITEM' AS check_name, '0' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[LNK_LINEITEM_PRODUCT] l
WHERE NOT EXISTS (SELECT 1 FROM [datavault].[HUB_LINEITEM] h WHERE h.HUB_ID = l.LINEITEM_HUB_ID);

SELECT 'orphan_LNK_LINEITEM_PRODUCT_PRODUCT' AS check_name, '0' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[LNK_LINEITEM_PRODUCT] l
WHERE NOT EXISTS (SELECT 1 FROM [datavault].[HUB_PRODUCT] h WHERE h.HUB_ID = l.PRODUCT_HUB_ID);

SELECT 'orphan_LNK_LINEITEM_TAX_LINEITEM' AS check_name, '0' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[LNK_LINEITEM_TAX] l
WHERE NOT EXISTS (SELECT 1 FROM [datavault].[HUB_LINEITEM] h WHERE h.HUB_ID = l.LINEITEM_HUB_ID);

SELECT 'orphan_LNK_LINEITEM_TAX_TAX' AS check_name, '0' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[LNK_LINEITEM_TAX] l
WHERE NOT EXISTS (SELECT 1 FROM [datavault].[HUB_TAX] h WHERE h.HUB_ID = l.TAX_HUB_ID);

SELECT 'orphan_LNK_DISCOUNT_LINEITEM_DISCOUNT' AS check_name, '0' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[LNK_DISCOUNT_LINEITEM] l
WHERE NOT EXISTS (SELECT 1 FROM [datavault].[HUB_DISCOUNT] h WHERE h.HUB_ID = l.DISCOUNT_HUB_ID);

SELECT 'orphan_LNK_DISCOUNT_LINEITEM_LINEITEM' AS check_name, '0' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[LNK_DISCOUNT_LINEITEM] l
WHERE NOT EXISTS (SELECT 1 FROM [datavault].[HUB_LINEITEM] h WHERE h.HUB_ID = l.LINEITEM_HUB_ID);

SELECT 'orphan_LNK_CUSTORDER_REVCENTER_CUSTORDER' AS check_name, '0' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[LNK_CUSTORDER_REVCENTER] l
WHERE NOT EXISTS (SELECT 1 FROM [datavault].[HUB_CUSTORDER] h WHERE h.HUB_ID = l.CUSTORDER_HUB_ID);

SELECT 'orphan_LNK_CUSTORDER_REVCENTER_REVCENTER' AS check_name, '0' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[LNK_CUSTORDER_REVCENTER] l
WHERE NOT EXISTS (SELECT 1 FROM [datavault].[HUB_REVCENTER] h WHERE h.HUB_ID = l.REVCENTER_HUB_ID);

SELECT 'orphan_LNK_ADDRESS_INDIVIDUAL_ADDRESS' AS check_name, '0' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[LNK_ADDRESS_INDIVIDUAL] l
WHERE NOT EXISTS (SELECT 1 FROM [datavault].[HUB_ADDRESS] h WHERE h.HUB_ID = l.ADDRESS_HUB_ID);

SELECT 'orphan_LNK_ADDRESS_INDIVIDUAL_INDIVIDUAL' AS check_name, '0' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[LNK_ADDRESS_INDIVIDUAL] l
WHERE NOT EXISTS (SELECT 1 FROM [datavault].[HUB_INDIVIDUAL] h WHERE h.HUB_ID = l.INDIVIDUAL_HUB_ID);

SELECT 'orphan_LNK_CONTACT_INDIVIDUAL_CONTACT' AS check_name, '0' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[LNK_CONTACT_INDIVIDUAL] l
WHERE NOT EXISTS (SELECT 1 FROM [datavault].[HUB_CONTACT] h WHERE h.HUB_ID = l.CONTACT_HUB_ID);

SELECT 'orphan_LNK_CONTACT_INDIVIDUAL_INDIVIDUAL' AS check_name, '0' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [datavault].[LNK_CONTACT_INDIVIDUAL] l
WHERE NOT EXISTS (SELECT 1 FROM [datavault].[HUB_INDIVIDUAL] h WHERE h.HUB_ID = l.INDIVIDUAL_HUB_ID);


/* ============================================================================
   SECTION E: Presentation checks
   Run in: the organisation's own database
   When: after the presentation layer rebuild completes for this org
   ============================================================================ */

SELECT 'presentation_F_LINEITEM_15MIN_nonzero' AS check_name, '>0' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [presentation].[F_LINEITEM_15MIN];

-- D_PRODUCT is already collapsed to one row per BOTTOM member (no
-- BOTTOM_LEVEL filter column exists in the presentation layer - every row
-- IS a bottom-level member, plus one sentinel row per table). Expect >= 279
-- + 1 sentinel = 280; use >= rather than exact equality since Mews product
-- data may grow between staging and presentation rebuild. Mews is this org's
-- sole integration (confirmed via core.OrganisationIntegrations), so no
-- other integration's products inflate this count today.
SELECT 'presentation_D_PRODUCT_bottom' AS check_name, '>=280' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) >= 280 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [presentation].[D_PRODUCT];

-- D_LOCATION: exact equality is safe here (2 Mews outlets + 1 sentinel = 3)
-- since Mews is this org's sole integration and outlet counts are stable.
SELECT 'presentation_D_LOCATION_total' AS check_name, '3' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 3 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [presentation].[D_LOCATION];

-- Ephemeral load-window parameters: NULL is the expected resting state,
-- meaning the last load cycle completed cleanly for this org. Non-NULL means
-- a load is in progress or failed mid-run. Absent rows are an equally valid
-- resting state, so the SUM is COALESCEd to 0 rather than left to evaluate
-- to NULL (which would otherwise fall through to the FAIL branch).
SELECT 'load_window_params_clear' AS check_name, 'NULL,NULL' AS expected,
       COALESCE(STRING_AGG(CONCAT(ParameterKey, '=', COALESCE(ParameterValue, 'NULL')), ', '), '(no rows)') AS actual,
       CASE WHEN COALESCE(SUM(CASE WHEN ParameterValue IS NOT NULL THEN 1 ELSE 0 END), 0) = 0
            THEN 'PASS' ELSE 'FAIL' END AS status
FROM [core].[GlobalParameters]
WHERE ParameterKey IN ('LINEITEM_START', 'LINEITEM_END');
