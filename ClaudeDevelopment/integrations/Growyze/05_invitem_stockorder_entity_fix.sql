/*
    Growyze Integration - INVITEM_STOCKORDER Entity Fix
    Target: [core].[core].[DataVaultEntities] + client database tables
    Date: 2026-03-06

    Problem: INVITEM_STOCKORDER entity definition has empty ATTRIBUTE_NAMES/ATTRIBUTE_TYPES.
    MarketMan's mapping only uses hub keys (no satellites), so the entity was created without
    attributes. Growyze mapping #17 maps 6 satellite columns (QUANTITY, PRICE, ESTIMATED_COST,
    ORDER_IN_CASE, CASE_SIZE, CASE_PRICE) which don't exist in the load/SAT_LNK tables.

    Error: LOG_DV id=191 "Process failed with error 207: Invalid column name 'QUANTITY'."

    Fix:
      Step 1 - Update DataVaultEntities to add the 6 satellite attributes
      Step 2 - Run sp_GenerateDataVaultTables to create SAT_LNK_INVITEM_STOCKORDER (new table)
      Step 3 - ALTER the existing load.INVITEM_STOCKORDER table to add missing columns
               (sp_GenerateDataVaultTables won't modify existing tables — IF NOT EXISTS guard)

    Deploy: Run Step 1 against core, then Step 2+3 against each affected org database.
*/

-- ============================================================================
-- STEP 1: Update entity definition (run against core)
-- ============================================================================

UPDATE [core].[core].[DataVaultEntities]
SET ATTRIBUTE_NAMES = N'["QUANTITY", "PRICE", "ESTIMATED_COST", "ORDER_IN_CASE", "CASE_SIZE", "CASE_PRICE"]',
    ATTRIBUTE_TYPES = N'[{"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": "Order line quantity"}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": "Order line price"}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": "Estimated cost of order line"}, {"data_type": "NVARCHAR(255)", "nullable": true, "business_key": false, "description": "Whether item is ordered by case"}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": "Case size for case orders"}, {"data_type": "DECIMAL(38,10)", "nullable": true, "business_key": false, "description": "Case price for case orders"}]',
    UPDATED_AT = GETDATE()
WHERE ENTITY_NAME = 'INVITEM_STOCKORDER'
  AND RELEASE_STATE = 'Live';

-- ============================================================================
-- STEP 2: Run sp_GenerateDataVaultTables for the target org
-- This creates SAT_LNK_INVITEM_STOCKORDER (new table) but won't modify existing tables
-- ============================================================================

-- EXEC [core].[core].[sp_GenerateDataVaultTables] @DatabaseName = '20251208_XMS_94A4B719-EB0F-421F-AD03-ABECDD888B14', @SchemaName = 'datavault', @ExecuteSQL = 1;

-- ============================================================================
-- STEP 3: ALTER existing load table to add missing satellite columns
-- sp_GenerateDataVaultTables skips existing tables (IF NOT EXISTS guard),
-- so we must add columns manually.
-- Run against each affected org database.
-- ============================================================================

-- Drop and recreate the load table (it's a transient working table, safe to recreate)
-- This is simpler than 6 individual ALTER ADD statements + PK rebuild

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[load].[INVITEM_STOCKORDER]') AND type in (N'U'))
BEGIN
    DROP TABLE [load].[INVITEM_STOCKORDER];
END;

CREATE TABLE [load].[INVITEM_STOCKORDER] (
    [LNK_ID] [BINARY](32) NOT NULL,
    [SRC] [NVARCHAR](255) NOT NULL,
    [LOAD_TS] [DATETIME2](7) NOT NULL,
    [INVITEM_HUB_ID] [BINARY](32) NOT NULL,
    [STOCKORDER_HUB_ID] [BINARY](32) NOT NULL,
    [QUANTITY] DECIMAL(38,10) NULL,
    [PRICE] DECIMAL(38,10) NULL,
    [ESTIMATED_COST] DECIMAL(38,10) NULL,
    [ORDER_IN_CASE] NVARCHAR(255) NULL,
    [CASE_SIZE] DECIMAL(38,10) NULL,
    [CASE_PRICE] DECIMAL(38,10) NULL,

    CONSTRAINT [PK_LOAD_INVITEM_STOCKORDER] PRIMARY KEY CLUSTERED ([LNK_ID] ASC, [LOAD_TS] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF,
          ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
    ON [PRIMARY]
) ON [PRIMARY];

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[load].[INVITEM_STOCKORDER]') AND name = N'IX_LOAD_INVITEM_STOCKORDER_LOAD_TS')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_LOAD_INVITEM_STOCKORDER_LOAD_TS]
    ON [load].[INVITEM_STOCKORDER] ([LOAD_TS] ASC);
END;
