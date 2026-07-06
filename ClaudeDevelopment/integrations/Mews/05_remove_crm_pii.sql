/* ============================================================================
   Mews Integration - Remove CRM lane (GDPR)
   Ruling 2026-07-03: guest names, home addresses, and email/phone contacts
   are GDPR-sensitive personal data with no current reporting need for the
   Mews integration. The CRM lane (INDIVIDUAL / ADDRESS / CONTACT hubs +
   ADDRESS_INDIVIDUAL / CONTACT_INDIVIDUAL links) is removed from staging and
   the DV load, and rows already loaded by the 2026-07-03 runs are purged.

   Scripts 01/02 no longer create these steps/mappings; this script removes
   what the first deployment already put in place. Idempotent - safe to re-run.

   SECTION A runs against the core database.
   SECTION B runs in the organisation's own database (org 19 for DEV).

   NOTE (fetcher team, out of scope here): [int_mews001].[DL_CUSTOMERS] in the
   landing layer still holds raw fullName/email/phone/address. Recommend
   removing the customers endpoint from the Mews fetch configuration and
   clearing the DL table, otherwise the PII re-lands on every fetch.
   ============================================================================ */

/* ============================================================================
   SECTION A: control-plane removal (run against core)
   ============================================================================ */

-- A1: entity mappings (hub + link rows, any source_table)
DELETE FROM [core].[int_mews001].[EntityMappings]
WHERE entity_name IN (N'INDIVIDUAL', N'ADDRESS', N'CONTACT',
                      N'ADDRESS_INDIVIDUAL', N'CONTACT_INDIVIDUAL');

-- A2: CRM staging steps
DELETE FROM [core].[int_mews001].[StagingControl]
WHERE step_type = N'Staging'
  AND step_name IN (N'Mews Customer', N'Mews Address', N'Mews Contact');

-- A3: generated DV Load steps
DELETE FROM [core].[int_mews001].[StagingControl]
WHERE step_type = N'Load'
  AND step_name IN (N'Data Vault load - INDIVIDUAL',
                    N'Data Vault load - ADDRESS',
                    N'Data Vault load - CONTACT',
                    N'Data Vault load - ADDRESS_INDIVIDUAL',
                    N'Data Vault load - CONTACT_INDIVIDUAL');

-- A4: verify (expect staging_steps=15, load_steps=16, entity_mappings=16, crm_rows=0)
SELECT 'staging_steps' AS check_name, COUNT(*) AS actual
FROM [core].[int_mews001].[StagingControl] WHERE step_type = 'Staging' AND exclude = 0
UNION ALL
SELECT 'load_steps', COUNT(*)
FROM [core].[int_mews001].[StagingControl] WHERE step_type = 'Load' AND exclude = 0
UNION ALL
SELECT 'entity_mappings', COUNT(*)
FROM [core].[int_mews001].[EntityMappings] WHERE is_active = 1
UNION ALL
SELECT 'crm_control_rows_remaining', COUNT(*)
FROM [core].[int_mews001].[EntityMappings]
WHERE entity_name IN (N'INDIVIDUAL', N'ADDRESS', N'CONTACT',
                      N'ADDRESS_INDIVIDUAL', N'CONTACT_INDIVIDUAL');


/* ============================================================================
   SECTION B: data purge (run in the organisation's own database)
   SRC filter keeps this safe on any org DB where another integration might
   also feed these shared entities; on Mews-only orgs it removes everything.
   Delete order: links -> satellites -> hubs.
   ============================================================================ */

-- B1: stage tables (hold raw names / addresses / contacts)
IF OBJECT_ID('stage.MEWS_CUSTOMER', 'U') IS NOT NULL DROP TABLE [stage].[MEWS_CUSTOMER];
IF OBJECT_ID('stage.MEWS_ADDRESS', 'U')  IS NOT NULL DROP TABLE [stage].[MEWS_ADDRESS];
IF OBJECT_ID('stage.MEWS_CONTACT', 'U')  IS NOT NULL DROP TABLE [stage].[MEWS_CONTACT];

-- B2: load tables (transient copies) + CDC hash tables
IF OBJECT_ID('load.INDIVIDUAL', 'U')         IS NOT NULL DELETE FROM [load].[INDIVIDUAL]         WHERE SRC = 'int_mews001';
IF OBJECT_ID('load.ADDRESS', 'U')            IS NOT NULL DELETE FROM [load].[ADDRESS]            WHERE SRC = 'int_mews001';
IF OBJECT_ID('load.CONTACT', 'U')            IS NOT NULL DELETE FROM [load].[CONTACT]            WHERE SRC = 'int_mews001';
IF OBJECT_ID('load.ADDRESS_INDIVIDUAL', 'U') IS NOT NULL DELETE FROM [load].[ADDRESS_INDIVIDUAL] WHERE SRC = 'int_mews001';
IF OBJECT_ID('load.CONTACT_INDIVIDUAL', 'U') IS NOT NULL DELETE FROM [load].[CONTACT_INDIVIDUAL] WHERE SRC = 'int_mews001';
IF OBJECT_ID('load.CDC_INDIVIDUAL', 'U')         IS NOT NULL TRUNCATE TABLE [load].[CDC_INDIVIDUAL];
IF OBJECT_ID('load.CDC_ADDRESS', 'U')            IS NOT NULL TRUNCATE TABLE [load].[CDC_ADDRESS];
IF OBJECT_ID('load.CDC_CONTACT', 'U')            IS NOT NULL TRUNCATE TABLE [load].[CDC_CONTACT];
IF OBJECT_ID('load.CDC_ADDRESS_INDIVIDUAL', 'U') IS NOT NULL TRUNCATE TABLE [load].[CDC_ADDRESS_INDIVIDUAL];
IF OBJECT_ID('load.CDC_CONTACT_INDIVIDUAL', 'U') IS NOT NULL TRUNCATE TABLE [load].[CDC_CONTACT_INDIVIDUAL];

-- B3: data vault links (incl. link satellites if deployed)
IF OBJECT_ID('datavault.SAT_LNK_ADDRESS_INDIVIDUAL', 'U') IS NOT NULL DELETE FROM [datavault].[SAT_LNK_ADDRESS_INDIVIDUAL] WHERE SRC = 'int_mews001';
IF OBJECT_ID('datavault.SAT_LNK_CONTACT_INDIVIDUAL', 'U') IS NOT NULL DELETE FROM [datavault].[SAT_LNK_CONTACT_INDIVIDUAL] WHERE SRC = 'int_mews001';
IF OBJECT_ID('datavault.LNK_ADDRESS_INDIVIDUAL', 'U') IS NOT NULL DELETE FROM [datavault].[LNK_ADDRESS_INDIVIDUAL] WHERE SRC = 'int_mews001';
IF OBJECT_ID('datavault.LNK_CONTACT_INDIVIDUAL', 'U') IS NOT NULL DELETE FROM [datavault].[LNK_CONTACT_INDIVIDUAL] WHERE SRC = 'int_mews001';

-- B4: satellites, then hubs
IF OBJECT_ID('datavault.SAT_INDIVIDUAL', 'U') IS NOT NULL DELETE FROM [datavault].[SAT_INDIVIDUAL] WHERE SRC = 'int_mews001';
IF OBJECT_ID('datavault.SAT_ADDRESS', 'U')    IS NOT NULL DELETE FROM [datavault].[SAT_ADDRESS]    WHERE SRC = 'int_mews001';
IF OBJECT_ID('datavault.SAT_CONTACT', 'U')    IS NOT NULL DELETE FROM [datavault].[SAT_CONTACT]    WHERE SRC = 'int_mews001';
IF OBJECT_ID('datavault.HUB_INDIVIDUAL', 'U') IS NOT NULL DELETE FROM [datavault].[HUB_INDIVIDUAL] WHERE SRC = 'int_mews001';
IF OBJECT_ID('datavault.HUB_ADDRESS', 'U')    IS NOT NULL DELETE FROM [datavault].[HUB_ADDRESS]    WHERE SRC = 'int_mews001';
IF OBJECT_ID('datavault.HUB_CONTACT', 'U')    IS NOT NULL DELETE FROM [datavault].[HUB_CONTACT]    WHERE SRC = 'int_mews001';

-- B5: verify purge (every count must be 0)
SELECT 'HUB_INDIVIDUAL' AS t, COUNT(*) AS remaining FROM [datavault].[HUB_INDIVIDUAL] WHERE SRC = 'int_mews001'
UNION ALL SELECT 'SAT_INDIVIDUAL', COUNT(*) FROM [datavault].[SAT_INDIVIDUAL] WHERE SRC = 'int_mews001'
UNION ALL SELECT 'HUB_CONTACT', COUNT(*) FROM [datavault].[HUB_CONTACT] WHERE SRC = 'int_mews001'
UNION ALL SELECT 'SAT_CONTACT', COUNT(*) FROM [datavault].[SAT_CONTACT] WHERE SRC = 'int_mews001'
UNION ALL SELECT 'HUB_ADDRESS', COUNT(*) FROM [datavault].[HUB_ADDRESS] WHERE SRC = 'int_mews001'
UNION ALL SELECT 'SAT_ADDRESS', COUNT(*) FROM [datavault].[SAT_ADDRESS] WHERE SRC = 'int_mews001'
UNION ALL SELECT 'LNK_CONTACT_INDIVIDUAL', COUNT(*) FROM [datavault].[LNK_CONTACT_INDIVIDUAL] WHERE SRC = 'int_mews001'
UNION ALL SELECT 'LNK_ADDRESS_INDIVIDUAL', COUNT(*) FROM [datavault].[LNK_ADDRESS_INDIVIDUAL] WHERE SRC = 'int_mews001'
UNION ALL SELECT 'stage_tables_remaining',
       CASE WHEN OBJECT_ID('stage.MEWS_CUSTOMER', 'U') IS NULL
             AND OBJECT_ID('stage.MEWS_ADDRESS', 'U') IS NULL
             AND OBJECT_ID('stage.MEWS_CONTACT', 'U') IS NULL THEN 0 ELSE 1 END;
